import 'dart:async';
import 'dart:isolate';

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
part './isolate/isolate.dart';

abstract class Store<T extends SimpleAction> {
    bool __inited = false;
    Store __parent;
    Store __connectedStore;
    _StateHolder _state;
    final _event = _EventHolder();

    Store() {
        _state = _StateHolder(_tag, debug);
    }

    Store connect(Store child) {
        Store c = child;
        while (c.__connectedStore != null) {
            c = c.__connectedStore;
        }
        c.__parent = this;
        c.__connectedStore = this;
        return child;
    }

    bool get debug => false;

    @protected
    Future<dynamic> dispatch(StoreSetter set, SimpleAction action) {
        if (set != null) {
            return _handle(set, action);
        }
        assert(() {
            if (debug) print('$_tag start dispatch $action');
            return true;
        }());

        set = StoreSetter._(false);
        return _handle(set, action)
            .then((value) {
                set._end();
                return value;
            })
            .whenComplete(() {
                assert(() {
                    if (debug) print('$_tag dispatch $action end');
                    return true;
                }());
            })
            .catchError((e, st) {
                onError(action, e, st);
            });
    }

    @protected
    void emit<T extends SimpleState>(T t, {dynamic name}) {
        _event.emit<T>(t, name: name);
    }

    @protected
    void init(StoreInitializer init);

    @protected
    Future<dynamic> handle(StoreSetter set, StoreGetter get, T action);

    @protected
    void dispose(StoreGetter get) {}

    @protected
    void onError(SimpleAction action, dynamic e, dynamic stack) {
        assert(() {
            if (debug) print('$_tag handle $action failed\n$e\n $stack');
            return true;
        }());
        throw e;
    }

    set _parent (Store parent) {
        if (__connectedStore != null) {
            __connectedStore._parent = parent;
        } else {
            __parent = parent;
        }
    }

    Store get _parent => __parent;


    bool _support(SimpleAction action) => action is T;

    Future<dynamic> _handle(StoreSetter set, SimpleAction action) async {
        if (_support(action)) {
            final sub = set._sub(this._state);
            final getter = StoreGetter._(this._state);
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
        final getter = StoreGetter._(this._state);
        try {
            dispose(getter);
        } finally {
            getter._end();
        }
        _state._dispose();
        __connectedStore?.__didDispose();
    }

    void _dispose() {
        assert(() {
            if (debug) print('$_tag will dispose');
            return true;
        }());
        this.__willDispose();
        this.__didDispose();
    }

    void _init() {
        __connectedStore?._init();
        final initializer = StoreInitializer._(this);
        init(initializer);
        initializer._end();
        __inited = true;
        assert(() {
            if (debug) print('$_tag inited');
            return true;
        }());
    }

    static Store _of(BuildContext context, bool required) {
        final s = context.findAncestorWidgetOfExactType<_StoreInheritedWidget>()?.store;
        assert(!required || s != null, 'Can not find a store from ancestors.');
        return s;
    }

    String get _tag => '$runtimeType';
}
