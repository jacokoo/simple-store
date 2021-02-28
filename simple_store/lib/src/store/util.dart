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

extension ContextDispatch on BuildContext {
    Future<dynamic> dispatch(SimpleAction action) {
        return Store._of(this, true).dispatch(null, action);
    }

    Future<dynamic> navTo<T extends SimplePage>(T state) {
        return Module._of(this).navTo(state);
    }

    void pop([dynamic result]) {
        Module._of(this).pop(result);
    }
}

abstract class StateOnlyStore extends Store {
    @override
    bool _support(SimpleAction action) => false;

    @override
    Future handle(StoreSetter set, StoreGetter get, SimpleAction action) {
        throw UnimplementedError('Can not reach here');
    }
}

class ReferenceCreator {
    final StoreInitializer _init;
    ReferenceCreator._(this._init);

    // call is not good for editor.
    void ref<T extends SimpleState>({dynamic name, ReferenceTransformer<T> setter}) {
        _init.ref<T>(name: name, setter: setter);
    }
}

class ReadOnlyStore extends StateOnlyStore {
    final void Function(ReferenceCreator) initializer;
    ReadOnlyStore([this.initializer]);

    @override
    @mustCallSuper
    void init(StoreInitializer init) {
        initializer(ReferenceCreator._(init));
    }
}

class _ValueStore<T> extends Store<_SetValueAction> {
    final T initialValue;
    final void Function(ReferenceCreator) initializer;
    _ValueStore({this.initialValue, this.initializer});

    @override
    Future handle(StoreSetter set, StoreGetter get, _SetValueAction action) async {
        set(_ValueState(action.value));
    }

    @override
    void init(StoreInitializer init) {
        init.state(_ValueState(initialValue));
        initializer(ReferenceCreator._(init));
    }
}

class _ValueState extends SimpleState {
    final dynamic value;
    _ValueState(this.value);
}

class _SetValueAction extends SimpleAction {
    final dynamic value;
    _SetValueAction(this.value);
}


typedef _Listener<T> = void Function(T);

class _Entry<T> extends LinkedListEntry<_Entry<T>> {
    final dynamic _listener;
    _Entry(this._listener);
}

mixin _Listenable<T> {
    final _listeners = LinkedList<_Entry>();

    VoidCallback _listen(_Listener<T> fn) {
        final entry = _Entry(fn);
        _listeners.add(entry);
        return () {
            if (entry.list != null ) entry.unlink();
        };
    }

    void _notify(T value) {
        final list = List<_Entry>.from(_listeners);
        for (final item in list) {
            if (item.list != null) item._listener(value);
        }
    }

    void _clearListeners() {
        _listeners.clear();
    }
}
