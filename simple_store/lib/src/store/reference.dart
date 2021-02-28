part of '../store.dart';


typedef ReferenceTransformer<T extends SimpleState> = void Function(T state, ReferenceSetter set);

class ReferenceSetter {
    final StoreSetter _setter;
    ReferenceSetter._(this._setter);

    bool get isInit => _setter._isInit;

    void call<T extends SimpleState>(T t, {dynamic name}) {
        _setter.call<T>(t, name: name);
    }
}

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

    void _dependTo<T extends SimpleState>(_StateReference store, _StateKey<T> key, ReferenceTransformer<T> transform, StoreSetter setter) {
        __refRemovers.add(store._addReference(key, this));
        final s = store._get(key);
        if (transform != null) {
            __refSetters[key] = transform;
        }
        _updateState(key, s, setter);
    }

    void _updateState<T extends SimpleState>(_StateKey<T> key, SimpleState v, StoreSetter set) {
        if (set._isInit || !__refSetters.containsKey(key)) {
            final sub = set._sub(this);
            sub._key(key, v);
        }

        if (__refSetters.containsKey(key)) {
            final setter = ReferenceSetter._(set._sub(this, isInit: false));
            __refSetters[key](v, setter);
        }
    }

    void _disposeReference() {
        __refRemovers.forEach((e) { e(); });
        __refRemovers = [];
        __refSetters = {};
        __refs = {};
    }
}
