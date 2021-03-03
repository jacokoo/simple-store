part of '../store.dart';

class _Initializer {
    bool _ended = false;

    void _end() {
        _ended = true;
    }

    T _do<T>(T Function() fn) {
        if (_ended) {
            throw InitializerEndedException(this);
        }
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

    void ref<T extends SimpleState>({dynamic name, ReferenceTransformer<T> setter}) {
        _do(() {
            final key = _StateKey<T>(T, name);
            var p = _owner._parent;
            while (p != null) {
                if (p._mayHaveState(key)) {
                    _owner._dependTo(p, key, setter, _setter);
                    return;
                }
                p = p._parent;
            }

            throw UnknownStateException(T, runtimeType);
        });
    }

    void state<T extends SimpleState>(T t, {dynamic name}) {
        _do(() {
            _owner._set(true, _StateKey<T>(T, name), t);
        });
    }

    void namedState<T extends SimpleState>(NamedStateInitializer<T> initializer) {
        _do(() {
            _owner._addNamed<T>(initializer);
        });
    }

    void event<T extends SimpleState>({dynamic name}) {
        _do(() {
            _owner._addEmitter(_StateKey<T>(T, name));
        });
    }

    void listen<T extends SimpleState>({dynamic name, _Listener<T> listener}) {
        _do(() {
            final key = _StateKey<T>(T, name);
            var p = _owner._parent;
            while (p != null) {
                if (p._haveEmitter(key)) {
                    _owner._listenTo(p, key, listener);
                    return;
                }
                p = p._parent;
            }

            throw UnknownEventException(T);
        });
    }
}
