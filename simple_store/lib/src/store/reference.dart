part of '../store.dart';


typedef ReferenceSetter<T extends SimpleState> = void Function(T state, StoreSetter set);

mixin _StateReference on _StateHolder {
    Map<_StateKey, List<_StateReference>> __refs = {};
    List<VoidCallback> __refRemovers = [];
    Map<_StateKey, dynamic> __refSetters = {};

    VoidCallback _addReference(_StateKey key, _StateReference store) {
        if (__refs.containsKey(key)) {
            __refs[key].add(store);
        } else {
            __refs[key] = [store];
        }

        return () {
            if (!__refs.containsKey(key)) return;
            __refs[key].remove(store);
            if (__refs[key].isEmpty) {
                __refs.remove(key);
            }
        };
    }

    bool _haveReference(_StateKey key) => __refs.containsKey(key);

    void _updateReference<T extends SimpleState>(StoreSetter set, _StateKey<T> key) {
        if (!_haveReference(key)) return;

        final s = _get(key);
        __refs[key].forEach((e) {
            e._updateState(key, s, set);
        });
    }

    void _dependTo<T extends SimpleState>(_StateReference store, _StateKey<T> key, ReferenceSetter<T> transform, StoreSetter setter) {
        __refRemovers.add(store._addReference(key, this));
        final s = store._get(key);
        if (transform != null) {
            __refSetters[key] = transform;
        }
        _updateState(key, s, setter);
    }

    void _updateState<T extends SimpleState>(_StateKey<T> key, SimpleState v, StoreSetter set) {
        set._push(this);
        if (__refSetters.containsKey(key)) {
            __refSetters[key](v, set);
        } else {
            set._key(key, v);
        }
        set._pop();
    }

    void _disposeReference() {
        __refRemovers.forEach((e) { e(); });
        __refRemovers = [];
        __refSetters = {};
        __refs = {};
    }
}
