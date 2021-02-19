part of '../store.dart';

mixin _EventHolder {
    Map<_StateKey, _Emitter> __emitters = {};
    List<VoidCallback> __listenerRemovers = [];

    void _addEmitter(_StateKey key) {
        __emitters[key] = _Emitter();
    }

    bool _haveEmitter(_StateKey key) => __emitters.containsKey(key);

    void _listenTo<T extends SimpleState>(_EventHolder owner, _StateKey<T> key, _Listener<T> listener) {
        final emitter = owner.__emitters[key];
        assert(emitter != null);
        __listenerRemovers.add(emitter._listen(listener));
    }

    void _disposeEvent() {
        __listenerRemovers.forEach((e) => e());
        __listenerRemovers = [];

        __emitters.values.forEach((e) => e._clearListeners());
        __emitters = {};
    }

    @protected
    void emit<T extends SimpleState>(T t, {dynamic name}) {
        final key = _StateKey<T>(T, name);
        final emitter = __emitters[key];
        assert(emitter != null);
        emitter._notify(t);
    }
}

class _Emitter with _Listenable {}
