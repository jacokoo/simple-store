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
        return '_StateKey<$T>($type, $name)';
    }
}

mixin _StateHolder on _Listenable<Set<_StateKey>> {
    Map<_StateKey, SimpleState> __state = {};
    Map<Type, NamedStateInitializer> __initializers = {};

    T _get<T extends SimpleState>(_StateKey<T> key) {
        if (!__state.containsKey(key)) {
            if (key.name != null && __initializers.containsKey(key.type)) {
                final v = __initializers[key.type](key.name);
                if (v != null) {
                    __state[key] = v;
                    return v;
                }
            }
            throw UnknownStateException(key.type, runtimeType);
        }
        return __state[key];
    }

    bool _set<T extends SimpleState>(bool isInit, _StateKey key, T t) {
        if (!isInit && !_mayHaveState(key)) {
            throw UnknownStateException(t, runtimeType);
        }
        if (__state[key] != t) {
            __state[key] = t;
            return true;
        }
        return false;
    }

    void _addNamed<T extends SimpleState>(NamedStateInitializer initializer) {
        __initializers[T] = initializer;
    }

    bool _mayHaveState(_StateKey key) =>
        __state.containsKey(key) || __initializers.containsKey(key.type);

    bool _haveState(_StateKey key) {
        if (__state.containsKey(key)) return true;
        if (key.name == null && __initializers.containsKey(key.type)) return true;
        return false;
    }

    void _disposeState() {
        __state = {};
        __initializers = {};
    }
}

class StoreSetter {
    final StoreSetter _parent;
    final _Initializer _init;
    final Map<_StateReference, Set<_StateKey>> _changed;
    final _StateReference _store;
    final bool _isInit;

    StoreSetter._(this._isInit): _init = _Initializer(), _changed = {}, _store = null, _parent = null;
    StoreSetter.__forSub(this._isInit, this._init, this._changed, this._store, this._parent) {
        if (!_changed.containsKey(_store)) {
            _changed[_store] = {};
        }
    }

    StoreSetter _sub(_StateReference store) {
        return StoreSetter.__forSub(_isInit, _init, _changed, store, this);
    }

    void call<T extends SimpleState>(T t, {dynamic name}) {
        final key = _StateKey<T>(T, name);
        _key(key, t);
    }

    void _key<T extends SimpleState>(_StateKey<T> key, T t) {
        _init._do(() {
            if (!_store._set(_isInit, key, t)) {
                return;
            }
            _changed[_store].add(key);

            if (_store._haveReference(key)) {
                _store._updateReference(this, key);
            }
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
