import 'package:built_collection/built_collection.dart';
import 'package:simple_store/simple_store.dart';

abstract class TodoAction extends CommonAction {}

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

class ActionAddTodo extends TodoAction {
    final String name;
    ActionAddTodo(this.name);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todo = Todo(_id ++, name, false);
        final todos = state.todos.rebuild((list) => list.add(todo));
        set(TodoState(state.filter, todos));
    }
}

class ActionDeleteTodo extends TodoAction {
    final int id;
    ActionDeleteTodo(this.id);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todos = state.todos.where((e) => e.id != id).toBuiltList();
        set(TodoState(state.filter, todos));
    }
}

class ActionClearCompletedTodos extends TodoAction {
    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final todos = state.todos.rebuild((list) => list..removeWhere((e) => e.completed));
        set(TodoState(state.filter, todos));
    }
}

class ActionFilterTodos extends TodoAction {
    final FilterType filter;
    ActionFilterTodos(this.filter);

    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        set(TodoState(filter, state.todos));
    }
}

class ActionToggleCompleteTodo extends TodoAction {
    final int id;
    ActionToggleCompleteTodo(this.id);

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

class ActionToggleAllTodos extends TodoAction {
    @override
    Future handle(StoreSetter set, StoreGetter get) async {
        final state = get<TodoState>();
        final any = state.todos.any((e) => !e.completed);
        set(TodoState(state.filter, state.todos.map((e) => Todo(e.id, e.name, any)).toBuiltList()));
    }
}

class ActionChangeName extends TodoAction {
    final int id;
    final String name;
    ActionChangeName(this.id, this.name);

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
