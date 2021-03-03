part of '../store.dart';

class SimpleStoreApp extends StatefulWidget {
    final Widget home;
    final Widget Function(RouterDelegate, RouteInformationParser) builder;
    SimpleStoreApp({
        @required this.home,
        @required this.builder
    });

    @override
    _SimpleStoreAppState createState() => _SimpleStoreAppState();
}

class _SimpleStoreAppState extends State<SimpleStoreApp> {
    _PageCollector collector;
    _RouterDelegate delegate;
    _RouteInfoParser parser;

    @override
    void initState() {
        super.initState();
        delegate = _RouterDelegate();
        parser = _RouteInfoParser();
        if (widget.home is Module) {
            final node = _ModuleNode(widget.home, delegate, null, false);
            node.init();
            collector = node;
        } else {
            collector = _RootPageCollector(widget.home, delegate);
        }

        delegate.collector = collector;
    }

    @override
    void dispose() {
        if (collector is _ModuleNode) {
            (collector as _ModuleNode).dispose();
        }
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        if (collector is _ModuleNode) {
            return _StoreInheritedWidget(
                store: (collector as _ModuleNode)._store,
                child: (_) => widget.builder(delegate, parser)
            );
        }

        return widget.builder(delegate, parser);
    }
}

abstract class _ChangeNotifier {
    void notify();
}

class _PageLocalKeyValue {
    final ModuleState state;
    final SimplePage page;
    _PageLocalKeyValue(this.state, this.page);

    @override
    String toString() => 'PageKey($state, $page)';
}

mixin _PageCollector {
    _PageCollector __parentCollector;
    final List<_PageCollector> _children = [];

    VoidCallback _addChild(_PageCollector node) {
        node.__parentCollector = this;
        _children.add(node);
        return () {
            node.__parentCollector = null;
            _children.remove(node);
        };
    }

    void _takePriority(_PageCollector node) {
        __parentCollector?._takePriority(this);
        assert(_children.contains(node));
        if (_children.last == node) return;
        _children..remove(node)..add(node);
    }

    List<Page> _childrenPages() {
        if (_children.isEmpty) return [];
        return _children.last.pages();
    }

    List<Page> pages();
    _ChangeNotifier get _notifier;
}

class _CollectorInheritedWidget extends InheritedWidget {
    final _PageCollector collector;
    final Widget child;
    _CollectorInheritedWidget(this.collector, this.child): super(child: child);

    @override
    bool updateShouldNotify(_CollectorInheritedWidget oldWidget) {
        return oldWidget.collector != collector;
    }
}

class _RouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin
    implements _ChangeNotifier {

    _PageCollector collector;

    @override
    Widget build(BuildContext context) {
        final ps = collector.pages();
        return Navigator(
            key: navigatorKey,
            pages: ps,
            onPopPage: (route, result) {
                if (!route.didPop(result)) {
                    return false;
                }
                _handleKey((route.settings as Page).key, result);
                return true;
            },
        );
    }

    @override
    final navigatorKey = GlobalKey<NavigatorState>();

    @override
    Future<void> setNewRoutePath(configuration) async {
        print('set new route path $configuration');
    }

    @override
    void notify() {
        notifyListeners();
    }

    void _handleKey(LocalKey key, result) {
        if (key is! ValueKey) return;
        final value = (key as ValueKey).value;

        if (value is! _PageLocalKeyValue) return;
        final vv = value as _PageLocalKeyValue;

        vv.state.pop(result);
    }
}

class _RouteInfoParser extends RouteInformationParser {
    @override
    Future parseRouteInformation(RouteInformation routeInformation) async {
        return Object();
    }
}
