part of '../store.dart';

class _ReferenceState<T extends SimpleState> extends _AbstractState implements _Reference {
    final _State _referred;
    final _StateHolder _store;
    VoidCallback _remover;
    _ReferenceState(this._referred, this._store) {
        _remover = _referred.addReference(null, this);
    }

    @override
    bool exists(name, exact) => _referred.exists(name, exact);

    @override
    SimpleState get(name) => _referred.get(name);

    @override
    bool doSet(name, SimpleState value) {
        assert(false, 'Can not update a reference state');
        return false;
    }

    @override
    Set<_StateHolder> collect(dynamic name) {
        return super.collect(name)..add(_store);
    }

    @override
    int delete(dynamic name) {
        _remover();
        return super.delete(name);
    }

    @override
    void deleted(_) {
        _store._del<T>(_StateKey(T, null));
    }

    @override
    String toString() {
        var s = 'ReferenceState';
        assert(() {
            s = '$s[$_referred]';
            return true;
        }());
        return s;
    }
}

class _EntireReferenceState<T extends SimpleState> extends _AbstractNamedState implements _Reference {
    final _State _referred;
    final _StateHolder _store;
    VoidCallback _remover;
    _EntireReferenceState(this._store, this._referred): assert(_referred is _AbstractNamedState) {
        _remover = _referred.addReference(null, this);
    }

    @override
    void deleted(name) {
        _store._del(_StateKey(T, name));
    }

    @override
    int doDelete(name) {
        assert(name == null);
        _remover();
        return 3;
    }

    @override
    bool doSet(name, SimpleState state) {
        assert(false, 'Can not update a reference state');
        return false;
    }

    @override
    bool exists(name, bool exact) {
        return _referred.exists(name, exact);
    }

    @override
    SimpleState get(name) {
        return _referred.get(name);
    }

    @override
    Set<_StateHolder> collect(dynamic name) {
        return super.collect(name)..add(_store);
    }

    @override
    String toString() {
        var s = 'EntireReferenceState';
        assert(() {
            s = '$s[$_referred]';
            return true;
        }());
        return s;
    }
}

class _NamedReferenceState<T extends SimpleState> extends _AbstractNamedState implements _Reference {
    final Set<dynamic> _names = {};
    final _State _referred;
    final _StateHolder _store;
    final Map<dynamic, VoidCallback> _removers = {};
    _NamedReferenceState(this._store, dynamic name, this._referred):
        assert(name != null), assert(_referred is _AbstractNamedState) {
        _removers[name] = _referred.addReference(name, this);
        _names.add(name);
    }

    @override
    void deleted(dynamic name) {
        _store._del(_StateKey(T, name));
    }

    @override
    int doDelete(name) {
        if (_names.contains(name)) {
            _names.remove(name);
            _removers[name]();
            return _names.isEmpty ? 3 : 1;
        }
        return 0;
    }

    @override
    bool doSet(name, SimpleState state) {
        assert(false, 'Can not update a reference state');
        return false;
    }

    @override
    bool exists(name, bool exact) {
        if (!_names.contains(name)) return false;
        return _referred.exists(name, exact);
    }

    @override
    SimpleState get(name) {
        assert(name != null && _names.contains(name));
        return _referred.get(name);
    }

    void merge(_NamedReferenceState other) {
        assert(_referred == other._referred);
        other._removers.values.forEach((e) => e());
        other._names.forEach((name) {
            assert(!_names.contains(name));
            _removers[name] = _referred.addReference(name, this);
            _names.add(name);
        });
    }

    @override
    Set<_StateHolder> collect(dynamic name) {
        if (!_names.contains(name)) return {};
        return super.collect(name)..add(_store);
    }

    @override
    String toString() {
        var s = 'NamedReferenceState';
        assert(() {
            s = '$s[$_referred] with names: $_names';
            return true;
        }());
        return s;
    }
}

/// A function that transform a parent state to local.
typedef Transformer<T extends SimpleState> = void Function(T state, TransformSetter set);

/// Used in Transformer, to update the state of current store.
class TransformSetter {
    final StoreSetter _setter;
    TransformSetter._(this._setter);

    /// Whether the transformer is the intialize run.
    bool get isInit => _setter._isInit;

    /// Update a state of current store.
    void call<T extends SimpleState>(T t, {dynamic name}) {
        _setter._key(_StateKey<T>(T, name), t);
    }
}

class _Transformer {
    final _StateHolder _store;
    final dynamic _transformer;
    _Transformer(this._store, this._transformer);

    void transform(SimpleState state, StoreSetter set) {
        _transformer(state, TransformSetter._(set._sub(_store)));
    }

    void deleted() {
        final remover = _store.__trans[this];
        remover();
        _store.__trans.remove(this);
    }
}
