part of '../store.dart';

/// Module holds a `Store` and create pages.
abstract class Module<K extends SimplePage> extends StatelessWidget with StoreCreator {
    /// The default page to show.
    K get defaultPage;

    /// Indicate only one page could be shown at one time.
    /// when navigate to a page, it will replace the previous one.
    bool get singleActive => false;

    /// Build page content for the specified page
    Widget buildPage(ModuleState module, K page);

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

    Store _createStore() => _ModuleStore<K>(defaultPage, singleActive ? 1 : 2).connect(createStore());
}

abstract class ModuleState {
    Future<dynamic> navTo(SimplePage page);
    void pop([dynamic result]);
}

mixin StoreNavigate<T extends SimpleAction> on Store<T> {
    Future<dynamic> navTo(StoreSetter set, SimplePage page) {
        return dispatch(set, _NavigateAction.navTo(page));
    }

    void pop(StoreSetter set, [dynamic result]) {
        dispatch(set, _NavigateAction.pop(result));
    }
}

abstract class PageState extends SimpleState with _$PageState {
    PageState._();
    factory PageState._create(Completer _completer, List<SimplePage> _stack) = _PageState;
    SimplePage get current => _stack.last;

    static PageState _new(SimplePage initialPage) {
        return PageState._create(null, [initialPage]);
    }
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
        _listenerRemover = _store._parent._listen((_) {
            _changePages(_currentPages(), false);
        });
        _changePages(_currentPages(), true);

        if (_module.initActions.isNotEmpty) {
            _postDispatchAction(_store, _module.initActions);
        }
    }

    Future<void> dispose() async {
        _listenerRemover();
        _disposePages(_shownPages);
        _shownPages = [];
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
    Future<dynamic> navTo(SimplePage page) {
        return _store._parent.dispatch(null, _NavigateAction.navTo(page)).then((value) {
            if (value == null) return null;
            return (value as _NavigateResult)._future;
        });
    }

    @override
    void pop([dynamic result]) {
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
        if (!isInit) _parent?._takePriority(this);
        if (_module.singleActive) {
            if (!isInit) {
                _children.clear();
                _notifier.notify();
            }
            return;
        }

        news.removeAt(0);
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
    VoidCallback remover;
    SimplePage current;
    final key = _StateKey<PageState>(PageState, null);

    @override
    void initState() {
        super.initState();
        node = _MountedModuleNode(widget._parentNode, widget._module, widget._parentNode._notifier, widget._parentStore);
        node.init();

        if (widget._module.singleActive) {
            current = widget._module.defaultPage;
            remover = node._store._parent._listen((_) {
                setState(() {
                    current = node._store._parent._get(key).current;
                });
            });
        }
    }

    @override
    void dispose() {
        if (remover != null) remover();
        node.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        if (!widget._module.singleActive) {
            return node._wrap(widget._module.buildPage(node, widget._module.defaultPage));
        }

        return node._wrap(widget._module.buildPage(node, current));
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
    final int _maxStackSize;
    _ModuleStore(this._intialPage, this._maxStackSize);

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
            if (state.current == p.page) {
                return null;
            }

            var stack = List<SimplePage>.from(state._stack);

            final idx = stack.indexOf(p.page);
            if (idx == -1) {
                if (stack.length >= _maxStackSize) {
                    stack.removeLast();
                }
                stack.add(p.page);
            } else {
                stack = stack.sublist(0, idx);
            }
            final completer = Completer();
            set(PageState._create(completer, stack));
            return _NavigateResult(completer.future);
        },

        pop: (p) async {
            final state = get<PageState>();

            if (state._stack.length > 1) {
                state._completer?.complete(p.result);

                final stack = List<SimplePage>.from(state._stack);
                stack.removeLast();

                set(PageState._create(null, stack));
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
        init.state(PageState._new(_intialPage));
    }
}
