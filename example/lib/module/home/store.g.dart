// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// ActionGenerator
// **************************************************************************

mixin _$HomeAction {
  Future<dynamic> _when(
      {@required Future<void> Function(_StoreTodos) storeTodos}) {
    if (this is _StoreTodos) return storeTodos(this);
    return null;
  }
}

class _StoreTodos extends HomeAction {
  final BuiltList<Todo> todos;
  const _StoreTodos(this.todos) : super._();

  @override
  String toString() {
    return 'HomeAction.storeTodos(todos: $todos)';
  }
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
}
