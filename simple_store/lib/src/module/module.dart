part of '../store.dart';

/// Module holds a `Store` and create pages.
abstract class Module<T extends SimplePage> extends _StatelessWidget with _StoreCreator<Module<T>> {
    /// The default page to show.
    T get defaultPage;

    /// Indicate only one page could be shown at one time.
    /// when navigate to a page, it will replace the previous one.
    bool get singleActive => false;

    /// Build page content for the specified page
    Widget buildPage(T page);

    /// Create `Page` object for navigation.
    Page createPage(Key key, Widget child) {
        return MaterialPage(child: child, key: key);
    }

    /// Whether the page is supported by current module
    bool support(SimplePage page) => page is T;

    /// Determine if the two pages are same.
    bool isSamePage(T t1, T t2) => t1 == t2;

    @override
    @nonVirtual
    Widget onBuild(BuildContext context) {
        final p = context.findAncestorWidgetOfExactType<_CollectorInheritedWidget>();
        assert(p != null);
        return _ModuleInnerWidget(p.collector, _StoreApi.of(context, false), this);
    }

    static _ModuleState _of(BuildContext context) {
        final node = context.findAncestorWidgetOfExactType<_CollectorInheritedWidget>()?.collector;
        assert(node != null && node is _ModuleState);
        return node as _ModuleState;
    }

    bool _allowEmpty(bool mounted) => mounted && this is ModuleBuilder;

    Store Function() _createModuleStore(bool mounted) => () => _ModuleStore(
        this,
        defaultPage,
        singleActive ? 1 : 2,
        _allowEmpty(mounted)
    );
}

/// Provide build method for Module.
mixin ModuleBuilder<T extends SimplePage> on Module<T> {
    /// with this mixin, defaultPage is optional.
    @override
    T get defaultPage => null;

    /// return the widget for the module when it is mounted to widget tree
    @protected
    Widget build(BuildContext context);
}

/// Provide navigation ability for Store.
mixin StoreNavigate<T extends SimpleAction> on Store<T> {

    /// Navigate to some page.
    Future<dynamic> navTo(StoreSetter set, SimplePage page) {
        return dispatch(set, _NavigateAction.navTo(page));
    }

    /// pop the top most page.
    void pop(StoreSetter set, [dynamic result]) {
        dispatch(set, _NavigateAction.pop(result));
    }
}

/// The navigation state of the current module.
/// One can reference this state to determine current page of the module.
abstract class PageState extends SimpleState with _$PageState {
    PageState._();
    factory PageState._create(Completer _completer, List<SimplePage> _stack) = _PageState;

    /// Get the current page.
    SimplePage get current => _stack.isEmpty ? null : _stack.last;

    static PageState _new(SimplePage initialPage) {
        return PageState._create(null, [initialPage]);
    }
}

abstract class _ModuleState {
    Future<dynamic> navTo(SimplePage page);
    void pop([dynamic result]);
}

class _ModuleNode extends _ModuleState with _PageCollector {
    final Module _module;
    final bool _mounted;
    _StoreApi _store;
    _StoreApi _moduleStore;

    VoidCallback _listenerRemover;
    List<SimplePage> _shownPages = [];
    final List<dynamic> _shownWidgets = [];

    _ModuleNode(_PageCollector collector, this._module, _StoreApi parent, this._mounted) {
        _moduleStore = _StoreApi(_module._createModuleStore(_mounted));
        _store = _moduleStore.connect(_StoreApi(_module.createStore));
        _store.setParent(parent);
        _parent = collector;
    }

    void init() {
        _store.init();
        _listenerRemover = _moduleStore.watch([_pageStateKey], (values) {
            _changePages(List.from((values[0] as PageState)._stack), false);
        });

        if (!_module._allowEmpty(_mounted)) {
            _changePages([_module.defaultPage], true);
        }
    }

    Future<void> dispose() async {
        _listenerRemover();
        _disposePages(0);
        _shownPages = [];
        _store.dispose();
    }

    void _changePages(List<SimplePage> news, bool isInit) {
        var i = 0;
        for (; i < news.length && i < _shownPages.length; i ++) {
            if (!_module.isSamePage(news[i], _shownPages[i])) {
                break;
            }
        }

        if (i == _shownPages.length) {
            _createPages(news.sublist(i));
        } else if (i == news.length) {
            _disposePages(i);
        } else {
            _disposePages(i);
            _createPages(news.sublist(i));
        }
        _shownPages = news;

        if (!isInit) {
            _takePriority();
            _notify();
        }
    }

    void _createPages(List<SimplePage> pages) {
        pages.forEach((e) {
            _shownPages.add(e);
            _shownWidgets.add(_createPage(_module.buildPage(e), e));
        });
    }

    void _disposePages(int idx) {
        for (var i = _shownPages.length - 1; i >= idx; i --) {
            _shownPages.removeLast();
            final w = _shownWidgets.removeLast();
            if (w is _ModuleNode) {
                w.dispose();
            }
        }
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
        assert(widget.defaultPage != null, 'Module[${widget.runtimeType}] is not mounted to widget tree, so the defaultPage must not be null.');
        final node = _ModuleNode(this, widget, _store, false);
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
        return _moduleStore.dispatch(_NavigateAction.navTo(page)).then((value) {
            if (value == null) return null;
            return (value as _NavigateResult)._future;
        });
    }

    @override
    void pop([dynamic result]) {
        _moduleStore.dispatch(_NavigateAction.pop(result));
    }

    @override
    List<Page> pages() {
        final re = <Page>[];
        _shownWidgets.forEach((w) {
            assert(w != null);
            if (w is! _ModuleNode) {
                re.add(w);
            } else if (w != _child) {
                re.addAll(w.pages());
            }
        });
        re.addAll(_childPages());
        return re;
    }
}

class _MountedModuleNode extends _ModuleNode {
    final bool useBuilder;
    _MountedModuleNode(
        _PageCollector collector, Module module, _StoreApi parent
    ): useBuilder = module is ModuleBuilder, super(collector, module, parent, true);

    @override
    void _changePages(List<SimplePage> news, bool isInit) {
        if (!useBuilder && news.isNotEmpty) news.removeAt(0);
        super._changePages(news, isInit);
    }
}

class _RootPageCollector with _PageCollector {
    final Widget child;
    _RootPageCollector(this.child);

    @override
    List<Page> pages() {
        return [
            _createRootPage(),
            ..._childPages()
        ];
    }

    Page _createRootPage() {
        return MaterialPage(key: ValueKey(this), child: _CollectorInheritedWidget(this, child));
    }
}

class _ModuleInnerWidget extends StatefulWidget {
    final _PageCollector _parentNode;
    final _StoreApi _parentStore;
    final Module _module;
    _ModuleInnerWidget(this._parentNode, this._parentStore, this._module);

    @override
    __ModuleInnerWidgetState createState() => __ModuleInnerWidgetState();
}

class __ModuleInnerWidgetState extends State<_ModuleInnerWidget> {
    _MountedModuleNode node;
    VoidCallback remover;
    SimplePage current;


    @override
    void initState() {
        super.initState();
        node = _MountedModuleNode(widget._parentNode, widget._module, widget._parentStore);
        node.init();

        current = widget._module.defaultPage;
        if (widget._module.singleActive && !node.useBuilder) {
            final store = node._moduleStore;

            remover = store.watch([_pageStateKey], (values) {
                final state = values[0] as PageState;
                assert(state._stack.isNotEmpty);
                final c = state._stack[0];
                if (!widget._module.isSamePage(c, current)) {
                    setState(() { current = c; });
                }
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
        return node._wrap(Builder(builder: (ctx) {
            if (node.useBuilder) {
                return (widget._module as ModuleBuilder).build(ctx);
            }
            return widget._module.buildPage(current);
        }));
    }

    @override
    void didUpdateWidget(_ModuleInnerWidget old) {
        super.didUpdateWidget(old);
        widget._module.didUpdateWidget(old._module, (SimpleAction action) => node._store.dispatch(action));
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

final _pageStateKey = _StateKey<PageState>(PageState, null);

class _ModuleStore<T extends SimplePage> extends Store<_NavigateAction> {
    final Module<T> _module;
    final dynamic _initialPage;
    final int _maxStackSize;
    final int _minStackSize;
    final bool _allowEmpty;
    _ModuleStore(this._module, this._initialPage, this._maxStackSize, this._allowEmpty): _minStackSize = _allowEmpty ? 0 : 1;

    @override
    Future handle(StoreSetter set, StoreGetter get, _NavigateAction action) => action._when(
        navTo: (p) async {
            if (!_module.support(p.page)) {
                assert(_parent != null, 'Unknown navigate action: $action');
                return _parent.dispatch(set, action);
            }

            final state = get<PageState>();
            if (_module.isSamePage(state.current, p.page)) {
                return;
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
            if (state._stack.length > _minStackSize) {
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
        if (_allowEmpty) {
            init.state(PageState._create(null, []));
            return;
        }

        assert(_initialPage != null);
        init.state(PageState._new(_initialPage));
    }
}
