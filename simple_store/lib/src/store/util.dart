part of '../store.dart';

abstract class _StatelessWidget extends ProxyWidget {
    _StatelessWidget({Key key}): super(child: null, key: key);

    @override
    Element createElement() => _StatelessElement(this);

    Widget onBuild(BuildContext context);
}

class _StatelessElement extends ProxyElement {
    _StatelessElement(_StatelessWidget widget) : super(widget);

    @override
    _StatelessWidget get widget => super.widget as _StatelessWidget;

    @override
    Widget build() => widget.onBuild(this);

    @override
    void notifyClients(covariant ProxyWidget oldWidget) {
    }
}

/// An extension to provide methods on BuildContext
extension ContextDispatch on BuildContext {

    /// Dispatch a action to current store.
    Future<dynamic> dispatch(SimpleAction action) {
        return _StoreApi.of(this, true).dispatch(action);
    }

    /// Navigate to a new page.
    Future<dynamic> navTo<T extends SimplePage>(T page) {
        return Module._of(this).navTo(page);
    }

    /// Pop the top most page.
    void pop([dynamic result]) {
        Module._of(this).pop(result);
    }
}

/// A Store that do not handle actions.
abstract class StateOnlyStore extends Store {
    @override
    bool support(SimpleAction action) => false;

    @override
    Future handle(StoreSetter set, StoreGetter get, SimpleAction action) {
        throw UnimplementedError('Can not reach here');
    }
}

/// This is a subset of StoreInitializer.
/// To limit the use of StoreInitializer for ReadOnlyStore.
class ReferenceCreator {
    final StoreInitializer _init;
    ReferenceCreator._(this._init);

    /// Reference a state from parent store.
    void ref<T extends SimpleState>({dynamic name}) {
        _init.ref<T>(name: name);
    }

    /// Transform a parent state.
    void transform<T extends SimpleState>(Transformer trans, {dynamic name}) {
        _init.transform(trans, name: name);
    }

    /// Listen event from parent store
    void listen<T extends SimpleState>({dynamic name, void Function(T) listener}) {
        _init.listen<T>(name: name, listener: listener);
    }
}

/// A function that dispatch actions.
typedef Dispatcher = Future<dynamic> Function(SimpleAction);

/// A store that is read only.
/// It can only reference state from parent store.
class ReadOnlyStore extends StateOnlyStore {

    /// The initializer to initialize the current store
    final void Function(ReferenceCreator, Dispatcher) initializer;

    /// Provide a name to debug info.
    final String debugName;
    ReadOnlyStore(this.debugName, [this.initializer]);

    @override
    @mustCallSuper
    void init(StoreInitializer init) {
        if (initializer == null) return;
        initializer(
            ReferenceCreator._(init),
            (action) => dispatch(null, action)
        );
    }

    @override
    String get _tag => 'ReadOnlyStore[$debugName]';
}

class _ValueStore<T> extends Store<_SetValueAction> {
    final T initialValue;
    final void Function(ReferenceCreator) initializer;
    _ValueStore({this.initialValue, this.initializer});

    @override
    Future handle(StoreSetter set, StoreGetter get, _SetValueAction action) async {
        set(__ValueState(action.value));
    }

    @override
    void init(StoreInitializer init) {
        init.state(__ValueState(initialValue));
        initializer(ReferenceCreator._(init));
    }
}

class __ValueState extends SimpleState {
    final dynamic value;
    __ValueState(this.value);
}

class _SetValueAction extends SimpleAction {
    final dynamic value;
    _SetValueAction(this.value);
}

class _Holder<T> {
    final Set<T> values = {};

    VoidCallback add(T t) {
        if (values.contains(t)) return () {};
        values.add(t);
        return () {
            values.remove(t);
        };
    }

    void forEach(void Function(T) fn) {
        Set<T>.from(values).forEach(fn);
    }

    Set<U> flat<U>(Set<U> Function(T) fn) {
        return values.fold({}, (acc, item) {
            acc.addAll(fn(item));
            return acc;
        });
    }
}

class _MapHolder<T> {
    Map<dynamic, Set<T>> values = {};

    VoidCallback add(dynamic key, T value) {
        if (!values.containsKey(key)) {
            values[key] = {};
        }

        if (values[key].contains(value)) return () {};

        values[key].add(value);
        return () {
            if (!values.containsKey(key)) return;
            if (!values[key].contains(value)) return;
            values[key].remove(value);
            if (values[key].isEmpty) {
                values.remove(key);
            }
        };
    }

    void forEach(dynamic name, void Function(T) fn) {
        if (!values.containsKey(name)) return;
        Set<T>.from(values[name]).forEach(fn);
    }

    Set<U> flat<U>(dynamic name, Set<U> Function(T) fn) {
        if (!values.containsKey(name)) return {};
        return values[name].fold({}, (acc, item) {
            acc.addAll(fn(item));
            return acc;
        });
    }

    void all(void Function(T) fn) {
        Map.from(values).entries.forEach((e) => Set<T>.from(e.value).forEach((ee) => fn(ee)));
    }

    Set<T> collect(Iterable<dynamic> keys) => keys.fold({}, (acc, item) {
        if (values.containsKey(item)) acc.addAll(values[item]);
        return acc;
    });

    void clear() {
        values.clear();
    }
}
