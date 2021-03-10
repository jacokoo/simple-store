part of '../store.dart';

class _Initializer {
    bool _ended = false;

    void _end() {
        _ended = true;
    }

    T _do<T>(T Function() fn) {
        assert(!_ended, 'Initializer is out of scope');
        return fn();
    }
}

class StoreInitializer with _Initializer {
    Store _owner;
    final StoreSetter _root = StoreSetter._(true);
    StoreSetter _setter;

    StoreInitializer._(this._owner) {
        _setter = _root._sub(_owner._state);
    }

    @override
    void _end() {
        super._end();
        _root._end();
    }

    void state<T extends SimpleState>(T t, {dynamic name}) {
        _do(() {
            _State state = name == null ? _ValueState(t) : _NamedState.value(name, t);
            _owner._state._add<T>(state);
        });
    }

    void namedState<T extends SimpleState>(NamedStateInitializer<T> initializer) {
        _do(() {
            _owner._state._add<T>(_NamedState(initializer));
        });
    }

    void event<T extends SimpleState>() {
        _do(() {
            _owner._event._add<T>();
        });
    }

    void ref<T extends SimpleState>({dynamic name}) {
        final key = _StateKey<T>(T, name);
        final result = __visiteParent((p) {
            if (p._state._mayHaveState(key)) {
                _owner._state._add<T>(p._state._createReference<T>(_owner._state, name));
                return true;
            }
        });
        assert(result, '$T is not found in ${_owner._tag}');
    }

    void transform<T extends SimpleState>(Transformer<T> transformer, {dynamic name}) {
        final key = _StateKey<T>(T, name);
        final result = __visiteParent((p) {
            if (p._state._mayHaveState(key)) {
                final trans = _Transformer(_owner._state, transformer);
                _owner._state.__trans[trans] = p._state._addTransformer<T>(key, trans, _setter);
                return true;
            }
        });
        assert(result, '$T is not found in ${_owner._tag}');
    }

    void listen<T extends SimpleState>({dynamic name, @required Listener<T> listener}) {
        final key = _StateKey<T>(T, name);
        final result = __visiteParent((p) {
            if (p._event._has<T>()) {
                _owner._event._listenTo(p._event, key, listener);
                return true;
            }
        });

        assert(result, 'Can not found event emitter for type $T');
    }

    bool __visiteParent(dynamic Function(Store) fn) {
        return _do(() {
            var p = _owner._parent;
            while (p != null) {
                if (fn(p) != null) return true;
                p = p._parent;
            }
            return false;
        });
    }
}
