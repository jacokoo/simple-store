// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// ActionGenerator
// **************************************************************************

mixin _$HomeAction {
  Future<dynamic> _when(
      {@required Future<void> Function(_StoreTodos) storeTodos}) {
    if (this is _StoreTodos) return storeTodos(this);
    assert(false, 'Unknown action instance: ActionGenerator');
    return null;
  }

  bool isType(bool storeTodos) {
    if (storeTodos != null && storeTodos && this is _StoreTodos) return true;
    return false;
  }
}

class _StoreTodos extends HomeAction {
  final BuiltList<Todo> todos;
  const _StoreTodos(this.todos) : super._();

  @override
  String toString() {
    return 'HomeAction.storeTodos(todos: $todos)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _StoreTodos && todos == o.todos);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(todos));
}

// **************************************************************************
// StateGenerator
// **************************************************************************

mixin _$TodoStorageState {
  BuiltList<Todo> get todos;

  TodoStorageState _copy({BuiltList<Todo> todos});
}

class _TodoStorageState extends TodoStorageState {
  final BuiltList<Todo> _todos;

  _TodoStorageState(this._todos) : super._();

  @override
  BuiltList<Todo> get todos => _todos;

  @override
  TodoStorageState _copy({Object todos = UNSET}) {
    return _TodoStorageState(
        todos == UNSET ? _todos : todos as BuiltList<Todo>);
  }

  @override
  String toString() {
    return 'TodoStorageState(todos: $todos)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _TodoStorageState && todos == o.todos);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(todos));
}
