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

abstract class Store<T extends SimpleAction> with _StateHolder, _StateReference, _EventHolder, _Listenable<Set<_StateKey>> {
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

        set = StoreSetter._(false);
        return _handle(set, action).whenComplete(() {
            set._end();
        }).catchError(onError);
    }

    @protected
    void init(StoreInitializer init);

    @protected
    Future<dynamic> handle(StoreSetter set, StoreGetter get, T action);

    @protected
    void dispose() {}

    @protected
    void onError(dynamic e) {
        if (__parent == null) {
            print(e);
            return;
        }
        __parent.onError(e);
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
            return _withSet(set, (getter) => handle(set, getter, action));
        }

        if (_parent != null) {
            return _parent._handle(set, action);
        }

        throw UnknownActionException(action);
    }

    Future<dynamic> _withSet(StoreSetter set, Future<dynamic> Function(StoreGetter) fn) {
        set._push(this);
        final getter = StoreGetter._(this);
        try {
            return fn(getter);
        } finally {
            getter._end();
            set._pop();
        }
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
