part of '../store.dart';

typedef NamedStateInitializer<T extends SimpleState> = T Function(dynamic name);

class _StateKey<T extends SimpleState> {
    final Type type;
    final dynamic name;
    _StateKey(this.type, this.name);

    @override
    bool operator ==(dynamic o) {
        return identical(this, o) || (o is _StateKey && type == o.type && name == o.name);
    }

    @override
    int get hashCode => hashValues(runtimeType, type, name);

    @override
    String toString() {
        return name == null ? 'Key($type)' : 'Key($type, $name)';
    }
}

abstract class _State {
    SimpleState get(dynamic name);

    bool exists(dynamic name, bool exact);

    // 0bxy x whether to remove, y whether changed
    int delete(dynamic name);

    bool set(dynamic name, SimpleState state, StoreSetter set);

    Set<Store> collect(dynamic name);

    VoidCallback addTransformer(dynamic name, _Transformer transformer);

    VoidCallback addReference(dynamic name, _Reference reference);

    void notifyDeleted(dynamic name);
}

abstract class _AbstractState extends _State {
    final references = _Holder<_Reference>();
    final transformers = _Holder<_Transformer>();

    VoidCallback addTransformer(dynamic name, _Transformer transformer) {
        assert(name == null);
        return transformers.add(transformer);
    }

    VoidCallback addReference(dynamic name, _Reference reference) {
        assert(name == null);
        return references.add(reference);
    }

    Set<Store> collect(dynamic name) {
        return references.flat((item) => item.collect(name));
    }

    bool set(dynamic name, SimpleState state, StoreSetter set) {
        assert(name == null);

        final result = doSet(name, state);
        if (result) {
            transformers.forEach((e) => e.transform(state, set));
        }
        return result;
    }

    bool doSet(dynamic name, SimpleState state);

    int delete(dynamic name) {
        assert(name == null);
        notifyDeleted(name);
        return 3;
    }

    void notifyDeleted(dynamic name) {
        assert(name == null);
        references.forEach((e) => e.deleted(name));
        transformers.forEach((e) => e.deleted());
    }
}

abstract class _AbstractNamedState extends _AbstractState {
    final namedTransformers = _MapHolder<_Transformer>();
    final namedReferences = _MapHolder<_Reference>();

    VoidCallback addTransformer(dynamic name, _Transformer transformer) {
        assert(name != null);
        return namedTransformers.add(name, transformer);
    }

    VoidCallback addReference(dynamic name, _Reference reference) {
        if (name == null) return super.addReference(name, reference);
        return namedReferences.add(name, reference);
    }

    Set<Store> collect(dynamic name) {
        if (name == null) return super.collect(name);
        return namedReferences.flat(name, (item) => item.collect(name));
    }

    int delete(dynamic name) {
        final result = doDelete(name);
        if (result & 2 == 2) {
            if (name == null) super.notifyDeleted(name);
            notifyDeleted(name);
        }
        return result;
    }

    int doDelete(dynamic name);

    bool set(dynamic name, SimpleState state, StoreSetter set) {
        assert(name != null);
        final result = doSet(name, state);
        if (result) {
            namedTransformers.forEach(name, (e) => e.transform(state, set));
        }
        return result;
    }

    void notifyDeleted(dynamic name) {
        if (name != null) {
            namedTransformers.forEach(name, (e) => e.deleted());
            namedReferences.forEach(name, (e) => e.deleted(name));
        } else {
            namedTransformers.all((e) => e.deleted());
            namedReferences.all((e) => e.deleted(name));
        }
    }
}

abstract class _Reference extends _State {
    void deleted(dynamic name);
}

class _ValueState extends _AbstractState {
    SimpleState _value;
    _ValueState(this._value);

    @override
    SimpleState get(name) {
        assert(name == null);
        return _value;
    }

    @override
    bool doSet(name, value) {
        if (_value == value) return false;

        _value = value;
        return true;
    }

    @override
    bool exists(name, exact) {
        return name == null;
    }

    @override
    String toString() {
        String s = 'ValueState';
        assert(() {
            s = 'ValueState[${_value.runtimeType}]';
            return true;
        }());
        return s;
    }
}

class _NamedState extends _AbstractNamedState {
    Map<dynamic, SimpleState> _states = {};
    NamedStateInitializer _initializer;
    _NamedState(this._initializer);
    _NamedState.value(dynamic name, SimpleState value): _initializer = null {
        _states[name] = value;
    }

    @override
    SimpleState get(name) {
        assert(name != null);
        if (_states.containsKey(name)) {
            return _states[name];
        }

        if (_initializer == null) return null;

        final value = _initializer(name);
        if (value != null) {
            _states[name] = value;
        }
        return value;
    }

    @override
    bool doSet(name, value) {
        if (_states[name] == value) return false;

        _states[name] = value;
        return true;
    }

    @override
    int doDelete(name) {
        if (name == null) {
            return _states.isEmpty ? 2 : 3;
        }
        if (!_states.containsKey(name)) return 0;
        _states.remove(name);
        return 1;
    }

    @override
    bool exists(name, exact) {
        if (name == null) return true;
        return exact ? _states.containsKey(name) : true;
    }

    void merge(_NamedState other) {
        assert(_initializer == null || _initializer == null);
        _initializer ??= other._initializer;
        _states.addAll(other._states);
    }

    @override
    String toString() {
        String s = 'NamedState';
        assert(() {
            final ss = _states.entries.map((e) => '(${e.key}, ${e.value.runtimeType})').join(',');
            s = '$s[$ss]';
            return true;
        }());
        return s;
    }
}

mixin _StateHolder on _Listenable<Set<_StateKey>> {
    Map<Type, _State> __state = {};
    Map<_Transformer, VoidCallback> __trans = {};

    T _get<T extends SimpleState>(_StateKey<T> key) {
        if (__state.containsKey(key.type)) {
            final state = __state[key.type].get(key.name);
            if (state != null) {
                return state;
            }
        }
        assert(false, '$key is not found in ${(this as Store)._tag}');
        return null;
    }

    Set<Store> _set<T extends SimpleState>(_StateKey<T> key, T t, StoreSetter set) {
        assert(__state.containsKey(key.type), '$key is not found in ${(this as Store)._tag}');
        final success = __state[key.type].set(key.name, t, set);
        if (success) return __state[key.type].collect(key.name)..add(this);
        return {};
    }

    // for init
    void _add<T extends SimpleState>(_State state) {
        if (!__state.containsKey(T)) {
            __state[T] = state;
            return;
        }

        if (state is _NamedState && __state[T] is _NamedState) {
            (__state[T] as _NamedState).merge(state);
            return;
        }

        if (state is _NamedReferenceState && __state[T] is _NamedReferenceState) {
            (__state[T] as _NamedReferenceState).merge(state);
            return;
        }

        assert(false, 'can not add state $T');
    }

    // for init
    VoidCallback _addTransformer<T extends SimpleState>(_StateKey<T> key, _Transformer trans, StoreSetter set) {
        final state = _get<T>(key);
        trans.transform(state, set);
        return __state[T].addTransformer(key.name, trans);
    }

    Set<Store> _del<T extends SimpleState>(_StateKey<T> key) {
        assert(__state.containsKey(key.type), '$key is not found in ${(this as Store)._tag}');
        final state = __state[key.type];
        final changed = state.collect(key.name)..add(this);

        final result = __state[key.type].delete(key.name);
        if (result & 2 == 2) {
            __state.remove(key.type);
        }
        return result & 1 == 1 ? changed : {};
    }

    bool _haveState(_StateKey key) {
        if (!__state.containsKey(key.type)) return false;
        return __state[key.type].exists(key.name, true);
    }

    bool _mayHaveState(_StateKey key) {
        if (!__state.containsKey(key.type)) return false;
        return __state[key.type].exists(key.name, false);
    }

    _Reference _createReference<T extends SimpleState>(Store sub, dynamic name) {
        final state = __state[T];
        if (state is _AbstractNamedState) {
            return name == null ?
                _EntireReferenceState<T>(sub, state) as _Reference :
                _NamedReferenceState<T>(sub, name, state);
        }

        return _ReferenceState<T>(state, sub);
    }

    void _disposeState() {
        __trans.values.forEach((e) => e());
        __trans.clear();

        __state.values.forEach((e) {
            assert(() {
                final store = this as Store;
                if (store.debug) {
                    print('${store._tag} dispose state $e');
                }
                return true;
            }());
            e.delete(null);
        });
        __state.clear();
    }
}

class StoreSetter {
    final StoreSetter _parent;
    final _Initializer _init;
    final Map<Store, Set<_StateKey>> _changed;
    final Store _store;
    final bool _isInit;

    StoreSetter._(this._isInit): _init = _Initializer(), _changed = {}, _store = null, _parent = null;
    StoreSetter.__forSub(this._isInit, this._init, this._changed, this._store, this._parent);

    StoreSetter _sub(Store store) {
        return StoreSetter.__forSub(_isInit, _init, _changed, store, this);
    }

    void call<T extends SimpleState>(T t, {dynamic name}) {
        final key = _StateKey<T>(T, name);
        _key(key, t);
    }

    /// caution: if delete a non-named state, it will not able to set the deleted type of state
    /// if delete a named state, the getters will get a default value from the namedInitializer
    void del<T extends SimpleState>({dynamic name}) {
        final key = _StateKey<T>(T, name);
        _init._do(() {
            final changed = _store._del(key);
            if (changed.isNotEmpty) _addChanged(changed, key);
        });
    }

    void _key<T extends SimpleState>(_StateKey<T> key, T t) {
        _init._do(() {
            final changed = _store._set(key, t, this);
            if (changed.isNotEmpty) _addChanged(changed, key);
        });
    }

    void _end() {
        assert(_parent == null);
        _init._end();

        if (!_isInit) {
            _changed.entries.forEach((e) {
                if (e.value.isEmpty) return;
                e.key._notify(e.value);
            });
        }
    }

    void _addChanged(Set<Store> stores, _StateKey key) {
        stores.forEach((e) {
            if (!_changed.containsKey(e)) _changed[e] = {};
            _changed[e].add(key);
        });
    }
}

class StoreGetter with _Initializer {
    final _StateHolder _owner;
    StoreGetter._(this._owner);

    T call<T extends SimpleState>({dynamic name}) {
        return _do(() => _owner._get(_StateKey<T>(T, name)));
    }

    bool has<T extends SimpleState>({dynamic name}) {
        return _do(() => _owner._haveState(_StateKey<T>(T, name)));
    }
}
