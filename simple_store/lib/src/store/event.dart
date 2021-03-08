part of '../store.dart';

mixin _EventHolder {
    Set<_StateKey> __emitters = {};
    Map<_StateKey, Set<dynamic>> __listeners = {};
    List<VoidCallback> __listenerRemovers = [];

    void _addEmitter(_StateKey key) {
        __emitters.add(key);
    }

    bool _haveEmitter(_StateKey key) => __emitters.contains(key);

    VoidCallback __addListener<T extends SimpleState>(_StateKey<T> key, _Listener<T> listener) {
        if (!__listeners.containsKey(key)) {
            __listeners[key] = {};
        }
        __listeners[key].add(listener);
        return () {
            if (!__listeners.containsKey(key)) return;
            __listeners[key].remove(listener);
            if (__listeners[key].isEmpty) {
                __listeners.remove(key);
            }
        };
    }

    void _listenTo<T extends SimpleState>(_EventHolder owner, _StateKey<T> key, _Listener<T> listener) {
        __listenerRemovers.add(owner.__addListener(key, listener));
    }

    void _disposeEvent() {
        __listenerRemovers.forEach((e) => e());
        __listenerRemovers = [];

        __listeners.clear();
        __emitters.clear();
    }

    @protected
    void emit<T extends SimpleState>(T t, {dynamic name}) {
        final key = _StateKey<T>(T, name);
        final ls = __listeners[key];
        if (ls == null || ls.isEmpty) return;
        final cp = List.from(ls);
        cp.forEach((e) => e(t));
    }
}
