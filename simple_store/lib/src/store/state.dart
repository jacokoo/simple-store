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
            throw UnknownStateException(key.type);
        }
        return __state[key];
    }

    bool _set<T extends SimpleState>(bool isInit, _StateKey key, T t) {
        if (!isInit && !__state.containsKey(key)) {
            throw UnknownStateException(t);
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

    bool _haveState(_StateKey key) =>
        __state.containsKey(key) || __initializers.containsKey(key.type);

    void _disposeState() {
        __state = {};
        __initializers = {};
    }
}

class StoreSetter with Initializer {
    bool _isInit = false;
    _StateReference _current;
    List<_StateReference> _stack = [];
    Map<_StateReference, Set<_StateKey>> _changed = {};
    int _count = 0;

    StoreSetter._(this._isInit);

    void _push(_StateReference store) {
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

    void _pop(_StateReference store) {
        if (_count != 0) {
            _count --;
            return;
        }
        final poped = _stack.removeLast();
        assert(identical(poped, store), '''
            Incorrect state.
            This might because StoreSetter is used when action dispatch is completed.
            Check if there are some async function called without await during action handle.
        ''');

        _current = _stack.isEmpty ? null : _stack.last;
    }

    void call<T extends SimpleState>(T t, {dynamic name}) {
        final key = _StateKey<T>(T, name);
        _key(key, t);
    }

    void _key<T extends SimpleState>(_StateKey<T> key, T t) {
        _do(() {
            if (!_current._set(_isInit, key, t)) {
                return;
            }
            _changed[_current].add(key);

            if (_current._haveReference(key)) {
                _current._updateReference(this, key);
            }
        });
    }

    @override
    void _end() {
        assert(_stack.isEmpty, 'stack $_stack is not empty');
        if (!_isInit) {
            _changed.entries.forEach((e) {
                e.key._notify(e.value);
            });
        }
        super._end();
    }
}

class StoreGetter with Initializer {
    final _StateHolder _owner;
    StoreGetter._(this._owner);

    T call<T extends SimpleState>({dynamic name}) {
        return _do(() => _owner._get(_StateKey<T>(T, name)));
    }

    bool has<T extends SimpleState>({dynamic name}) {
        return _do(() => _owner._haveState(_StateKey<T>(T, name)));
    }
}
