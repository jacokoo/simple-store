part of '../store.dart';

/// A function used to listen event.
typedef Listener<T> = void Function(T);

class _EventHolder {
    final Set<Type> __emitters = {};
    final __holder = _MapHolder<dynamic>();
    List<VoidCallback> __removers = [];

    void _add<T extends SimpleState>() {
        __emitters.add(T);
    }

    bool _has<T extends SimpleState>() => __emitters.contains(T);

    void _listenTo<T extends SimpleState>(_EventHolder owner, _StateKey<T> key, Listener<T> listener) {
        __removers.add(owner.__holder.add(key, listener));
    }

    void emit<T extends SimpleState>(T t, {dynamic name}) {
        __holder.forEach(_StateKey<T>(T, name), (e) => e(t));
    }

    void _dispose() {
        __removers.forEach((e) => e());
        __removers = [];

        __holder.clear();
        __emitters.clear();
    }
}

typedef _Watcher = void Function(List<SimpleState>);

class _WatchEntry {
    final List<_StateKey> keys;
    final _Watcher watcher;
    _WatchEntry(this.keys, this.watcher);
}

class _StateWatcher {
    final _StateHolder __store;
    final __holder = _MapHolder<_WatchEntry>();

    _StateWatcher(this.__store);

    VoidCallback _watch(List<_StateKey> keys, _Watcher fn) {
        final entry = _WatchEntry(keys, fn);
        final removers = keys.map((e) => __holder.add(e, entry)).toList();
        return () {
            removers.forEach((e) => e());
        };
    }

    void _notify(Set<_StateKey> keys) {
        if (keys.isEmpty) return;
        __holder.collect(keys).forEach((entry) {
            final values = entry.keys.map((e) => __store._get(e)).toList();
            entry.watcher(values);
        });
    }

    void _dispose() {
        __holder.clear();
    }
}
