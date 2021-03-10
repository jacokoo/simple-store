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
        _setter = _root._sub(_owner);
    }

    @override
    void _end() {
        super._end();
        _root._end();
    }

    void state<T extends SimpleState>(T t, {dynamic name}) {
        _do(() {
            _State state = name == null ? _ValueState(t) : _NamedState.value(name, t);
            _owner._add<T>(state);
        });
    }

    void namedState<T extends SimpleState>(NamedStateInitializer<T> initializer) {
        _do(() {
            _owner._add<T>(_NamedState(initializer));
        });
    }

    void event<T extends SimpleState>() {
        _do(() {
            _owner._addEmitter(_StateKey<T>(T, null));
        });
    }

    void ref<T extends SimpleState>({dynamic name}) {
        final key = _StateKey<T>(T, name);
        final result = __visiteParent((p) {
            if (p._mayHaveState(key)) {
                _owner._add<T>(p._createReference<T>(_owner, name));
                return true;
            }
        });
        assert(result, '$T is not found in ${_owner._tag}');
    }

    void transform<T extends SimpleState>(Transformer<T> transformer, {dynamic name}) {
        final key = _StateKey<T>(T, name);
        final result = __visiteParent((p) {
            if (p._mayHaveState(key)) {
                final trans = _Transformer(_owner, transformer);
                _owner.__trans[trans] = p._addTransformer<T>(key, trans, _setter);
                return true;
            }
        });
        assert(result, '$T is not found in ${_owner._tag}');
    }

    void listen<T extends SimpleState>({dynamic name, @required _Listener<T> listener}) {
        final emitterKey = _StateKey<T>(T, null);
        final listenerKey = _StateKey<T>(T, name);
        final result = __visiteParent((p) {
            if (p._haveEmitter(emitterKey)) {
                _owner._listenTo(p, listenerKey, listener);
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
