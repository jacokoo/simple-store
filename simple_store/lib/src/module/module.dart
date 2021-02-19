part of '../store.dart';

/// Module holds a `Store` and create pages.
abstract class Module<K extends SimplePage> extends StatelessWidget with StoreCreator {
    /// The default page to show.
    K get defaultPage;

    /// Build page content for the specified page
    Widget buildPage(ModuleState nav, K page);

    /// Create `Page` object for navigation.
    Page createPage(Key key, Widget child) {
        return MaterialPage(child: child, key: key);
    }

    @override
    @nonVirtual
    Widget build(BuildContext context) {
        final p = context.findAncestorWidgetOfExactType<_CollectorInheritedWidget>();
        assert(p != null);
        return _ModuleInnerWidget(p.collector, Store._of(context, false), this);
    }

    static ModuleState of(BuildContext context) {
        final node = context.findAncestorWidgetOfExactType<_CollectorInheritedWidget>()?.collector;
        assert(node != null && node is ModuleState);
        return node as ModuleState;
    }

    Store _createStore() => _ModuleStore<K>(defaultPage).connect(createStore());
}

abstract class ModuleState {
    Future<dynamic> to(SimplePage page);
    void pop(dynamic result);
}

class PageState extends SimpleState {
    Completer _completer;
    List<SimplePage> _stack;
    PageState._(SimplePage intialPage): _stack = [intialPage];

    SimplePage get current => _stack.last;
}

class _ModuleNode extends ModuleState with _PageCollector {
    final Module _module;
    final _ChangeNotifier __notifier;
    final Store _store;

    VoidCallback _listenerRemover;
    List<SimplePage> _shownPages = [];
    Map<SimplePage, dynamic> _shownWidgets = {};

    _ModuleNode(this._module, this.__notifier, Store parent): _store = _module._createStore() {
        _store._parent = parent;
    }

    void init() {
        _store._init();
        _listenerRemover = _store._parent._listen((v) {
            _changePages(_currentPages(), false);
        });
        _changePages(_currentPages(), true);

        if (_module.initActions.isNotEmpty) {
            _postDispatchAction(_store, _module.initActions);
        }
    }

    Future<void> dispose() async {
        _listenerRemover();
        _store._willCallDispose();
        await Future.wait(_module.disposeActions.map((e) => _store.dispatch(null, e)));
        _store.dispose();
    }

    List<SimplePage> _currentPages() {
        final state = _store._parent._get(_StateKey<PageState>(PageState, null));
        return List.from(state._stack);
    }

    void _changePages(List<SimplePage> news, bool isInit) {
        int i = 0;
        for (; i < news.length && i < _shownPages.length; i ++) {
            if (news[i] != _shownPages[i]) {
                break;
            }
        }

        if (i == _shownPages.length) {
            _createPages(news.sublist(i));
        } else if (i == news.length) {
            _disposePages(_shownPages.sublist(i));
        } else {
            _disposePages(_shownPages.sublist(i));
            _createPages(news.sublist(i));
        }
        _shownPages = news;

        if (!isInit) _notifier.notify();
    }

    void _createPages(List<SimplePage> pages) {
        pages.forEach((e) {
            _shownWidgets[e] = _createPage(_module.buildPage(this, e), e);
        });
    }

    void _disposePages(List<SimplePage> pages) {
        pages.forEach((e) {
            final w = _shownWidgets.remove(e);
            if (w is _ModuleNode) {
                w.dispose();
            }
        });
    }

    ValueKey _pageKey(SimplePage page) {
        return ValueKey(_PageLocalKeyValue(this, page));
    }

    dynamic _createPage(Widget widget, SimplePage page) {
        if (widget is Module) {
            return _createModulePage(widget);
        }

        return _createNormalPage(widget, page);
    }

    Page _createNormalPage(Widget widget, SimplePage page) {
        return _module.createPage(_pageKey(page), _wrap(widget));
    }

    _ModuleNode _createModulePage(Module widget) {
        final node = _ModuleNode(widget, _notifier, this._store);
        node.init();
        return node;
    }

    Widget _wrap(Widget child) {
        return _CollectorInheritedWidget(this, _StoreInheritedWidget(
            store: _store,
            child: (_) => child,
        ));
    }

    @override
    Future<dynamic> to(SimplePage page) {
        print('nav to $page');
        return _store._parent.dispatch(null, _NavigateAction.navTo(page)).then((value) {
            if (value == null) return null;
            return (value as _NavigateResult)._future;
        });
    }

    @override
    void pop(dynamic result) {
        _store._parent.dispatch(null, _NavigateAction.pop(result));
    }

    @override
    List<Page> pages() {
        final re = <Page>[];
        _shownPages.forEach((e) {
            final w = _shownWidgets[e];
            assert(w != null);
            if (w is _ModuleNode) {
                re.addAll(w.pages());
            } else {
                re.add(w);
            }
        });
        re.addAll(_childrenPages());
        return re;
    }

    @override
    _ChangeNotifier get _notifier => __notifier;
}

class _MountedModuleNode extends _ModuleNode {
    VoidCallback _remover;
    final _PageCollector _parent;

    _MountedModuleNode(
        this._parent, Module module, _ChangeNotifier notifier, Store parent
    ): super(module, notifier, parent);

    void init() {
        super.init();
        _remover = _parent?._addChild(this);
    }

    Future<void> dispose() {
        if (_remover != null) _remover();
        return super.dispose();
    }

    void _changePages(List<SimplePage> news, bool isInit) {
        news.removeAt(0);
        if (!isInit) _parent?._takePriority(this);
        super._changePages(news, isInit);
    }
}

class _RootPageCollector with _PageCollector {
    final Widget child;
    final _ChangeNotifier __notifier;
    _RootPageCollector(this.child, this.__notifier);

    @override
    _ChangeNotifier get _notifier => __notifier;

    @override
    List<Page> pages() {
        return [
            _createRootPage(),
            ..._childrenPages()
        ];
    }

    Page _createRootPage() {
        return MaterialPage(key: ValueKey(this), child: _CollectorInheritedWidget(this, child));
    }
}

class _ModuleInnerWidget extends StatefulWidget {
    final _PageCollector _parentNode;
    final Store _parentStore;
    final Module _module;
    _ModuleInnerWidget(this._parentNode, this._parentStore, this._module);

    @override
    __ModuleInnerWidgetState createState() => __ModuleInnerWidgetState();
}

class __ModuleInnerWidgetState extends State<_ModuleInnerWidget> {
    _MountedModuleNode node;

    @override
    void initState() {
        super.initState();
        node = _MountedModuleNode(widget._parentNode, widget._module, widget._parentNode._notifier, widget._parentStore);
        node.init();
    }

    @override
    void dispose() {
        node.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return node._wrap(widget._module.buildPage(node, widget._module.defaultPage));
    }
}


abstract class _NavigateAction extends SimpleAction with _$_NavigateAction {
    const _NavigateAction._();
    const factory _NavigateAction.navTo(SimplePage page) = _NavTo;
    const factory _NavigateAction.pop(dynamic result) = _Pop;
}

class _NavigateResult {
    final Future<dynamic> _future;
    _NavigateResult(this._future);
}

class _ModuleStore<T extends SimplePage> extends Store<_NavigateAction> {
    final dynamic _intialPage;
    _ModuleStore(this._intialPage);

    @override
    Future handle(StoreSetter set, StoreGetter get, _NavigateAction action) => action._when(
        navTo: (p) async {
            if (p.page is! T) {
                if (_parent == null) {
                    throw UnknownActionException(action);
                }
                return _parent.dispatch(set, action);
            }

            final state = get<PageState>();
            var stack = state._stack;

            if (stack.last == p.page) {
                return null;
            }

            state._completer = Completer();

            final idx = stack.indexOf(p.page);
            if (idx == -1) {
                if (stack.length >= 2) {
                    stack.removeLast();
                }
                stack.add(p.page);
            } else {
                stack = stack.sublist(0, idx);
            }

            state._stack = stack;
            set(state);

            return _NavigateResult(state._completer.future);
        },

        pop: (p) async {
            final state = get<PageState>();

            if (state._stack.length > 1) {
                state._stack.removeLast();
                state._completer?.complete(p.result);
                state._completer = null;
                set(state);
                return true;
            }

            if (_parent != null) {
                return _parent.dispatch(set, action);
            }

            return false;
        }
    );

    @override
    void init(StoreInitializer init) {
        init.state(PageState._(_intialPage));
    }
}

mixin _$_NavigateAction {
    Future<dynamic> _when({
        @required Future<void> Function(_NavTo) navTo,
        @required Future<void> Function(_Pop) pop
    }) {
        if (this is _NavTo) return navTo(this);
        if (this is _Pop) return pop(this);
        return null;
    }
}

class _NavTo extends _NavigateAction {
    final SimplePage page;
    const _NavTo(this.page): super._();

    @override
    String toString() {
        return '_NavigateAction.push(page: $page)';
    }
}

class _Pop extends _NavigateAction {
    final dynamic result;
    const _Pop(this.result) : super._();

    @override
    String toString() {
        return '_NavigateAction.pop(result: $result)';
    }
}
