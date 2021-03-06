part of '../store.dart';

mixin StoreCreator {
    Store createStore();
}

abstract class Component extends _StatelessWidget with StoreCreator {
    final Key key;
    Component({this.key}): super(key: key);

    Widget build(BuildContext context);

    @override
    Widget onBuild(BuildContext context) {
        return _StoreWidget(Store._of(context, false), this, build);
    }
}

abstract class ValueComponent<T> extends _StatelessWidget with StoreCreator {
    final T _initialValue;
    final _StoreAware _aware = _StoreAware();
    ValueComponent({T intialValue, Key key}): _initialValue = intialValue, super(key: key);

    void init(ReferenceCreator init) {}

    @override
    @nonVirtual
    Store createStore() {
        return _ValueStore<T>(initialValue: _initialValue, initializer: init);
    }

    @override
    @nonVirtual
    Widget onBuild(BuildContext context) {
        return _StoreWidget(Store._of(context, false), this, build, _aware);
    }

    Widget build(BuildContext context);

    Widget watch({Widget Function(T) builder}) {
        return Watch<_ValueState>(builder: (vs) => builder(vs.value));
    }

    Future<dynamic> set(T t) {
        return _aware((store) => store.dispatch(null, _SetValueAction(t)));
    }
}

class Watch<T extends SimpleState> extends _Watch {
    Watch({Widget Function(T t) builder, dynamic name}):
            super(builder: (d) => builder(d[0]), watchedKeys: [_StateKey<T>(T, name)]);
}

class Watch2<T extends SimpleState, T2 extends SimpleState> extends _Watch {
    Watch2({Widget Function(T t, T2 t2) builder, dynamic name1, dynamic name2}):
            super(builder: (d) => builder(d[0], d[1]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2)]);
}

class Watch3<T extends SimpleState, T2 extends SimpleState, T3 extends SimpleState> extends _Watch {
    Watch3({Widget Function(T t, T2 t2, T3 t3) builder, dynamic name1, dynamic name2, dynamic name3}):
            super(builder: (d) => builder(d[0], d[1], d[2]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2), _StateKey<T3>(T3, name3)]);
}

class Watch4<T extends SimpleState, T2 extends SimpleState, T3 extends SimpleState, T4 extends SimpleState> extends _Watch {
    Watch4({Widget Function(T t, T2 t2, T3 t3, T4 t4) builder, dynamic name1, dynamic name2, dynamic name3, dynamic name4}):
            super(builder: (d) => builder(d[0], d[1], d[2], d[3]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2), _StateKey<T3>(T3, name3), _StateKey<T4>(T4, name4)]);
}

class Watch5<T extends SimpleState, T2 extends SimpleState, T3 extends SimpleState, T4 extends SimpleState, T5 extends SimpleState> extends _Watch {
    Watch5({Widget Function(T t, T2 t2, T3 t3, T4 t4, T5 t5) builder, dynamic name1, dynamic name2, dynamic name3, dynamic name4, dynamic name5}):
            super(builder: (d) => builder(d[0], d[1], d[2], d[3], d[4]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2), _StateKey<T3>(T3, name3), _StateKey<T4>(T4, name4), _StateKey<T5>(T5, name5)]);
}

class Get<T extends SimpleState> extends _Get {
    Get({Widget Function(T t) builder, dynamic name}):
            super(builder: (d) => builder(d[0]), watchedKeys: [_StateKey<T>(T, name)]);
}

class Get2<T extends SimpleState, T2 extends SimpleState> extends _Get {
    Get2({Widget Function(T t, T2 t2) builder, dynamic name1, dynamic name2}):
            super(builder: (d) => builder(d[0], d[1]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2)]);
}

class Get3<T extends SimpleState, T2 extends SimpleState, T3 extends SimpleState> extends _Get {
    Get3({Widget Function(T t, T2 t2, T3 t3) builder, dynamic name1, dynamic name2, dynamic name3}):
            super(builder: (d) => builder(d[0], d[1], d[2]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2), _StateKey<T3>(T3, name3)]);
}

class Get4<T extends SimpleState, T2 extends SimpleState, T3 extends SimpleState, T4 extends SimpleState> extends _Get {
    Get4({Widget Function(T t, T2 t2, T3 t3, T4 t4) builder, dynamic name1, dynamic name2, dynamic name3, dynamic name4}):
            super(builder: (d) => builder(d[0], d[1], d[2], d[3]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2), _StateKey<T3>(T3, name3), _StateKey<T4>(T4, name4)]);
}

class Get5<T extends SimpleState, T2 extends SimpleState, T3 extends SimpleState, T4 extends SimpleState, T5 extends SimpleState> extends _Get {
    Get5({Widget Function(T t, T2 t2, T3 t3, T4 t4, T5 t5) builder, dynamic name1, dynamic name2, dynamic name3, dynamic name4, dynamic name5}):
            super(builder: (d) => builder(d[0], d[1], d[2], d[3], d[4]), watchedKeys: [_StateKey<T>(T, name1), _StateKey<T2>(T2, name2), _StateKey<T3>(T3, name3), _StateKey<T4>(T4, name4), _StateKey<T5>(T5, name5)]);
}

class _StoreInheritedWidget extends InheritedWidget {
    final Store store;
    _StoreInheritedWidget({this.store, WidgetBuilder child}): super(child: Builder(builder: child));

    @override
    bool updateShouldNotify(covariant _StoreInheritedWidget oldWidget) {
        return oldWidget.store != store;
    }
}

class _StoreAware {
    Store _store;

    dynamic call(dynamic Function(Store) fn) {
        assert(_store != null);
        return fn(_store);
    }
}

class _StoreWidget<T extends SimpleAction> extends StatefulWidget {
    final Store parent;
    final WidgetBuilder child;
    final StoreCreator creator;
    final _StoreAware aware;
    _StoreWidget(this.parent, this.creator, this.child, [this.aware]);

    @override
    __StoreWidgetState createState() => __StoreWidgetState();
}

class __StoreWidgetState extends State<_StoreWidget> {
    Store store;
    @override
    void initState() {
        super.initState();

        store = widget.creator.createStore();
        store._parent = widget.parent;
        store._init();

        widget.aware?._store = store;

        assert(() {
            print('store: ${store.runtimeType} inited');
            return true;
        }());
    }

    @override
    Widget build(BuildContext context) {
        return _StoreInheritedWidget(store: store, child: widget.child);
    }

    @override
    void dispose() {
        assert(() {
            print('store: ${store.runtimeType} disposed');
            return true;
        }());
        widget.aware?._store = null;
        store._dispose();
        super.dispose();
    }
}

class _InnerStoreWidget extends StatefulWidget {
    final Store store;
    final Widget Function(List<dynamic>) builder;
    final List<_StateKey> watchedKeys;
    _InnerStoreWidget(this.store, this.builder, this.watchedKeys);

    @override
    State<StatefulWidget> createState() => __InnerStoreWidgetState();
}

class __InnerStoreWidgetState extends State<_InnerStoreWidget> {
    VoidCallback remover;

    Store getStore() => widget.store;

    @override
    void initState() {
        super.initState();

        if (widget.watchedKeys.isNotEmpty) {
            remover = widget.store._listen((data) {
                if (widget.watchedKeys.any((it) => data.contains(it))) {
                    setState(() {});
                }
            });
        }
    }

    @override
    void dispose() {
        if (remover != null) remover();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final values = widget.watchedKeys.map((it) => widget.store._get(it)).toList();
        return widget.builder(values);
    }
}

class _Watch extends StatelessWidget {
    final List<_StateKey> watchedKeys;
    final Widget Function(List<dynamic>) builder;

    _Watch({this.watchedKeys, this.builder});

    @override
    Widget build(BuildContext context) {
        return _InnerStoreWidget(Store._of(context, true), builder, watchedKeys);
    }
}

class _Get extends StatelessWidget {
    final List<_StateKey> watchedKeys;
    final Widget Function(List<dynamic>) builder;

    _Get({this.watchedKeys, this.builder});

    @override
    Widget build(BuildContext context) {
        final store = Store._of(context, true);
        return builder(watchedKeys.map((e) => store._get(e)).toList());
    }
}
