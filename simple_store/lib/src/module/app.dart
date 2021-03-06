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
        if (widget.home is Module) {
            final node = _ModuleNode(null, widget.home, null, false);
            node.init();
            collector = node;
        } else {
            collector = _RootPageCollector(widget.home);
        }

        parser = _RouteInfoParser();
        delegate = _RouterDelegate(collector);
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
    final _ModuleState state;
    final SimplePage page;
    _PageLocalKeyValue(this.state, this.page);

    @override
    String toString() => 'PageKey($state, $page)';
}

mixin _PageCollector {
    _PageCollector _parent;
    _PageCollector _child;
    _ChangeNotifier __notifier;

    void _takePriority() {
        _parent?._takePriority();
        _parent?._child = this;
        this._child = null;
    }

    List<Page> _childPages() {
        return _child?.pages() ?? [];
    }

    void _notify() {
        if (_parent != null) return _parent._notify();
        assert(__notifier != null);
        __notifier.notify();
    }

    List<Page> pages();
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

    final _PageCollector collector;
    _RouterDelegate(this.collector) {
        collector.__notifier = this;
    }

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

        if (value is _PageLocalKeyValue) {
            value.state.pop(result);
        }
    }
}

class _RouteInfoParser extends RouteInformationParser {
    @override
    Future parseRouteInformation(RouteInformation routeInformation) async {
        return Object();
    }
}
