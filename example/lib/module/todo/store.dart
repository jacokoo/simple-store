import 'package:built_collection/built_collection.dart';
import 'package:example/module/home/store.dart';
import 'package:simple_store/simple_store.dart';

part 'store.g.dart';

@value
abstract class Todo with _$Todo {
    Todo._();
    factory Todo(int id, String name, bool completed) = _Todo;
}

enum FilterType { All, Active, Completed }

@state
abstract class TodoState extends SimpleState with _$TodoState {
    TodoState._();

    factory TodoState._create(FilterType filter, BuiltList<Todo> todos) = _TodoState;

    BuiltList<Todo> get _filtered {
        if (filter == FilterType.All) return todos;
        if (filter == FilterType.Active) return todos.where((e) => !e.completed).toBuiltList();
        return todos.where((e) => e.completed).toBuiltList();
    }
}

@action
abstract class TodoAction extends SimpleAction with _$TodoAction {
    const TodoAction._();

    const factory TodoAction.add(String name) = _Add;
    const factory TodoAction.del(int id) = _Del;
    const factory TodoAction.clearCompleted() = _ClearCompleted;
    const factory TodoAction.filter(FilterType filter) = _Filter;
    const factory TodoAction.toggleComplete(int id) = _ToggleComplete;
    const factory TodoAction.toggleAll() = _ToggleAll;
    const factory TodoAction.changeName(int id, String name) = _ChangeName;

    const factory TodoAction.storeTodos() = _StoreTodos;
}

var id = 0;

class TodoStore extends Store<TodoAction> {
    @override
    void init(StoreInitializer init) {
        init.ref<TodoStorageState>(setter: (hs, set) {
            set(TodoState._create(FilterType.All, hs.todos));
        });
    }

    @override
    Future handle(StoreSetter set, StoreGetter get, TodoAction action) => action._when(
        add: (p) async {
            final state = get<TodoState>();
            final todo = Todo(id ++, p.name, false);
            set(state._copy(todos: state.todos.rebuild((list) => list.add(todo))));
        },

        del: (p) async {
            final state = get<TodoState>();
            set(state._copy(
                todos: state.todos.rebuild((list) =>
                    list..removeWhere((e) => e.id == p.id)))
            );
        },

        clearCompleted: (_) async {
            final state = get<TodoState>();
            set(state._copy(
                todos: state.todos.rebuild((list) =>
                    list..removeWhere((e) => e.completed)))
            );
        },

        filter: (p) async {
            final state = get<TodoState>();
            set(state._copy(filter: p.filter));
        },

        toggleComplete: (p) async {
            final state = get<TodoState>();
            final idx = state.todos.indexWhere((e) => e.id == p.id);
            final nl = state.todos.rebuild((list) {
                final todo = state.todos[idx];
                list[idx] = todo.copy(completed: !todo.completed);
            });
            set(state._copy(todos: nl));
        },

        toggleAll: (_) async {
            final state = get<TodoState>();
            final any = state.todos.any((e) => !e.completed);
            final nl = state.todos.map((e) => e.completed == any ? e : e.copy(completed: any)).toBuiltList();
            set(state._copy(todos: nl));
        },

        changeName: (p) async {
            final state = get<TodoState>();
            final idx = state.todos.indexWhere((e) => e.id == p.id);
            final nl = state.todos.rebuild((list) {
                final todo = state.todos[idx];
                list[idx] = todo.copy(name: p.name);
            });
            set(state._copy(todos: nl));
        },

        storeTodos: (_) async {
            await dispatch(set, HomeAction.storeTodos(get<TodoState>().todos));
        }
    );

}
