import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_store_base/simple_store_base.dart';

part './store/state.dart';
part './store/init.dart';
part './store/reference.dart';
part './store/widget.dart';
part './store/event.dart';
part './store/util.dart';

part './module/module.dart';
part './module/app.dart';
part './module/generated.dart';

/// Store is to hold state objects and handle action
abstract class Store<T extends SimpleAction> {
    Store __parent;
    Store __connectedStore;
    _StateHolder _state;
    final _event = _EventHolder();

    Store() {
        _state = _StateHolder(_tag, debug);
    }

    /// Compose two stores as one.
    /// The current store is used as a parent of child store.
    /// Returns the composed store.
    Store connect(Store child) {
        var c = child;
        while (c.__connectedStore != null) {
            c = c.__connectedStore;
        }
        c.__parent = this;
        c.__connectedStore = this;
        return child;
    }

    /// Whether to show debug info
    bool get debug => false;

    /// Dispatch actions during handling action.
    @protected
    Future<dynamic> dispatch(StoreSetter set, SimpleAction action) {
        if (set != null) {
            return _handle(set, action);
        }

        set = StoreSetter._(false);
        return _handle(set, action)
            .then((value) {
                set._end();
                return value;
            })
            .catchError((e, st) {
                onError(action, e, st);
            });
    }

    /// Emit a boardcast event to child stores
    @protected
    void emit<S extends SimpleState>(S t, {dynamic name}) {
        _event.emit<S>(t, name: name);
    }

    /// Override this method to initialize the state of current store.
    @protected
    void init(StoreInitializer init);

    /// Override this to handle incoming actions.
    @protected
    Future<dynamic> handle(StoreSetter set, StoreGetter get, T action);

    /// This method is invoked when the store is disposing.
    /// All listeners are removed before call this.
    /// State will be cleard after call this.
    @protected
    void dispose(StoreGetter get) {}

    /// Handle errors from action handling.
    @protected
    void onError(SimpleAction action, dynamic e, dynamic stack) {
        assert(() {
            if (debug) print('$_tag handle $action failed\n$e\n $stack');
            return true;
        }());
        throw e;
    }

    /// Whether the action is supported by current store.
    @protected
    bool support(SimpleAction action) => action is T;

    set _parent (Store parent) {
        if (__connectedStore != null) {
            __connectedStore._parent = parent;
        } else {
            __parent = parent;
        }
    }

    Store get _parent => __parent;

    Future<dynamic> _handle(StoreSetter set, SimpleAction action) async {
        if (support(action)) {
            final sub = set._sub(_state);
            final getter = StoreGetter._(_state);
            try {
                return await handle(sub, getter, action);
            } finally {
                getter._end();
            }
        }

        if (_parent != null) {
            return _parent._handle(set, action);
        }

        assert(false, 'Unknown action: $action');
    }

    void __willDispose() {
        _state._watcher._dispose();
        _event._dispose();
        __connectedStore?.__willDispose();
    }

    void __didDispose() {
        final getter = StoreGetter._(_state);
        try {
            dispose(getter);
        } finally {
            getter._end();
        }
        _state._dispose();
        __connectedStore?.__didDispose();
    }

    void _dispose() {
        __willDispose();
        __didDispose();
    }

    void _init() {
        __connectedStore?._init();
        final initializer = StoreInitializer._(this);
        init(initializer);
        initializer._end();
    }

    String get _tag => '$runtimeType';
}

class _StoreApi {
    final Store store;
    _StoreApi(Store Function() creator): store = creator();

    void setParent(_StoreApi parent) {
        if (parent == null) return;
        store._parent = parent.store;
    }

    _StoreApi connect(_StoreApi child) {
        store.connect(child.store);
        return child;
    }

    void init() {
        store._init();
        assert(() {
            if (store.debug) print('${store._tag} inited');
            return true;
        }());
    }

    void dispose() {
        assert(() {
            if (store.debug) print('${store._tag} will dispose');
            return true;
        }());
        store._dispose();
    }

    VoidCallback watch(List<_StateKey> keys, _Watcher watcher) {
        return store._state._watcher._watch(keys, watcher);
    }

    Future<dynamic> dispatch(SimpleAction action) {
        assert(() {
            if (store.debug) print('${store._tag} start dispatch $action');
            return true;
        }());
        final result = store.dispatch(null, action);
        assert(() {
            result.whenComplete(() {
                if (store.debug) print('${store._tag} dispatch $action end');
            });
            return true;
        }());
        return result;
    }

    List<SimpleState> get(List<_StateKey> keys) {
        return keys.map((e) => store._state._get(e)).toList();
    }

    static _StoreApi of(BuildContext context, bool required) {
        final s = context.findAncestorWidgetOfExactType<_StoreInheritedWidget>()?.store;
        assert(!required || s != null, 'Can not find a store from ancestors.');
        return s;
    }
}
