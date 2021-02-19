part of '../store.dart';


typedef NamedStateInitializer<T extends SimpleState> = T Function(dynamic name);

class _StateKey<T extends SimpleState> {
    final Type type;
    final dynamic name;
    _StateKey(this.type, this.name);

    @override
    bool operator ==(dynamic o) {
        return identical(o, this) ||
            (o is _StateKey && identical(type, o.type) && identical(name, o.name));
    }

    @override
    int get hashCode => hashValues(runtimeType, type, name);

    @override
    String toString() {
        return '_StateKey<$T>($type, $name)';
    }
}

mixin _StateHolder {
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
            throw UnknownStateException(key.type);
        }
        return __state[key];
    }

    void _set<T extends SimpleState>(bool isInit, _StateKey key, T t) {
        if (!isInit && !__state.containsKey(key)) {
            throw UnknownStateException(T);
        }
        __state[key] = t;
    }

    void _addNamed<T extends SimpleState>(NamedStateInitializer initializer) {
        __initializers[T] = initializer;
    }

    bool _haveState(_StateKey key) =>
        __state.containsKey(key) || __initializers.containsKey(key.type);

    void _disposeState() {
        __state = {};
        __initializers = {};
    }
}

class StoreSetter with Initializer {
    bool _isInit = false;
    Store _current;
    List<Store> _stack = [];
    Map<Store, Set<_StateKey>> _changed = {};
    int _count = 0;

    StoreSetter._(this._isInit);

    void _push(Store store) {
        if (store == _current) {
            _count ++;
            return;
        }

        _current = store;
        _stack.add(store);
        if (!_changed.containsKey(store)) {
            _changed[store] = {};
        }
    }

    void _pop() {
        if (_count != 0) {
            _count --;
            return;
        }

        _current = _stack.removeLast();
    }

    void call<T extends SimpleState>(T t, {dynamic name}) {
        _do(() {
            final key = _StateKey<T>(T, name);
            _current._set(_isInit, key, t);
            _changed[_current].add(key);

            if (_current._haveReference(key)) {
                _current._updateReference(this, key);
            }
        });
    }

    void _key<T extends SimpleState>(_StateKey key, T t) {
        _do(() {
            _current._set(_isInit, key, t);
            _changed[_current].add(key);
        });
    }

    @override
    void _end() {
        assert(_stack.isEmpty);
        if (!_isInit) {
            _changed.entries.forEach((e) {
                e.key._notify(e.value);
            });
        }
        super._end();
    }
}

class StoreGetter with Initializer {
    final Store _owner;
    StoreGetter._(this._owner);

    T call<T extends SimpleState>({dynamic name}) {
        return _do(() => _owner._get(_StateKey<T>(T, name)));
    }
}
