import 'package:built_collection/built_collection.dart';
import 'package:simple_store/simple_store.dart';

abstract class TodoAction extends CommonAction {
    TodoAction();

    factory TodoAction.add(String name) = _ActionAddTodo;
    factory TodoAction.del(int id) = _ActionDeleteTodo;
    factory TodoAction.clearCompleted() = _ActionClearCompleted;
    factory TodoAction.filter(FilterType filter) = _ActionFilterTodos;
    factory TodoAction.toggleComplete(int id) = _ActionToggleComplete;
    factory TodoAction.toggleAll() = _ActionToggleAll;
    factory TodoAction.changeName(int id, String name) = _ActionChangeName;
}

class TodoStore extends CommonStore {
    @override
    bool support(SimpleAction action) => action is TodoAction;

    @override
    void init(StoreInitializer init) {
        init.state(TodoState(FilterType.All, BuiltList.from([])));
    }
}

class Todo {
    final int id;
    final String name;
    final bool completed;
    Todo(this.id, this.name, this.completed);
}

enum FilterType { All, Active, Completed }

class TodoState implements SimpleState {
    final FilterType filter;
    final BuiltList<Todo> todos;
    TodoState(this.filter, this.todos);

    List<Todo> get filtered {
        if (filter == FilterType.All) return todos.toList();
        if (filter == FilterType.Active) return todos.where((e) => !e.completed).toList();
        return todos.where((e) => e.completed).toList();
    }
}

int _id = 0;

class _ActionAddTodo extends TodoAction {
    final String name;
    _ActionAddTodo(this.name);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todo = Todo(_id ++, name, false);
        final todos = state.todos.rebuild((list) => list.add(todo));
        set(TodoState(state.filter, todos));
    }
}

class _ActionDeleteTodo extends TodoAction {
    final int id;
    _ActionDeleteTodo(this.id);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todos = state.todos.where((e) => e.id != id).toBuiltList();
        set(TodoState(state.filter, todos));
    }
}

class _ActionClearCompleted extends TodoAction {
    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todos = state.todos.rebuild((list) => list..removeWhere((e) => e.completed));
        set(TodoState(state.filter, todos));
    }
}

class _ActionFilterTodos extends TodoAction {
    final FilterType filter;
    _ActionFilterTodos(this.filter);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        set(TodoState(filter, state.todos));
    }
}

class _ActionToggleComplete extends TodoAction {
    final int id;
    _ActionToggleComplete(this.id);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todos = state.todos.map((e) {
            if (e.id == id) {
                return Todo(e.id, e.name, !e.completed);
            }
            return e;
        }).toBuiltList();
        set(TodoState(state.filter, todos));
    }
}

class _ActionToggleAll extends TodoAction {
    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final any = state.todos.any((e) => !e.completed);
        set(TodoState(state.filter, state.todos.map((e) => Todo(e.id, e.name, any)).toBuiltList()));
    }
}

class _ActionChangeName extends TodoAction {
    final int id;
    final String name;
    _ActionChangeName(this.id, this.name);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todos = state.todos.map((e) => e.id == id ? Todo(id, name, e.completed) : e);
        set(TodoState(state.filter, todos.toBuiltList()));
    }
}

abstract class CommonAction implements SimpleAction {
    CommonStore store;

    Future<dynamic> handle(StoreSetter set, StoreGetter get);

    Future<dynamic> dispatch(StoreSetter set, SimpleAction action) {
        return store.doDispatch(set, action);
    }

    void emit(SimpleState state, {dynamic name}) {
        store.doEmit(state, name: name);
    }
}

abstract class CommonStore extends Store<CommonAction> {
    @override
    Future handle(StoreSetter set, StoreGetter get, CommonAction action) {
        action.store = this;
        return action.handle(set, get);
    }

    // another dispatch
    // the dispatch method on Store is protected
    Future<dynamic> doDispatch(StoreSetter set, SimpleAction action) {
        return dispatch(set, action);
    }

    void doEmit(SimpleState state, {dynamic name}) {
        emit(state, name: name);
    }
}
