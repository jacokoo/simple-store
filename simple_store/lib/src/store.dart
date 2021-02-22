import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'exception.dart';
import 'package:simple_store_base/simple_store_base.dart';

part './store/state.dart';
part './store/init.dart';
part './store/reference.dart';
part './store/widget.dart';
part './store/event.dart';
part './store/util.dart';

part './module/module.dart';
part './module/app.dart';

abstract class Store<T extends SimpleAction> with _Listenable<Set<_StateKey>>, _StateHolder, _StateReference, _EventHolder {
    Store __parent;
    Store __connectedStore;

    Store connect(Store child) {
        child.__parent = this;
        child.__connectedStore = this;
        return child;
    }

    @protected
    Future<dynamic> dispatch(StoreSetter set, SimpleAction action) {
        if (set != null) {
            return _handle(set, action);
        }
        assert(() {
            print('$runtimeType start dispatch $action');
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
                    print('$runtimeType dispatch $action end');
                    return true;
                }());
            })
            .catchError(onError);
    }

    @protected
    void init(StoreInitializer init);

    @protected
    Future<dynamic> handle(StoreSetter set, StoreGetter get, T action);

    @protected
    void dispose() {}

    @protected
    void onError(dynamic e, dynamic stack) {
        if (__parent == null) {
            print('$e\n $stack');
            throw e;
        }
        __parent.onError(e, stack);
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
            set._push(this);
            final getter = StoreGetter._(this);
            try {
                return await handle(set, getter, action);
            } finally {
                getter._end();
                set._pop(this);
            }
        }

        if (_parent != null) {
            return _parent._handle(set, action);
        }

        throw UnknownActionException(action);
    }

    // Call this method before dispatch disposeActions
    // This is to release the listeners of current store.
    void _willCallDispose() {
        __connectedStore?._willCallDispose();
        _clearListeners();
        _disposeReference();
        _disposeEvent();
    }

    void _dispose() {
        __connectedStore?._dispose();
        this._willCallDispose();
        _disposeState();
        dispose();
    }

    void _init() {
        __connectedStore?._init();

        final initializer = StoreInitializer._(this);
        init(initializer);
        initializer._end();
    }

    static Store _of(BuildContext context, bool required) {
        final s = context.findAncestorWidgetOfExactType<_StoreInheritedWidget>()?.store;
        assert(!required || s != null, 'Can not find a store from ancestors.');
        return s;
    }
}
