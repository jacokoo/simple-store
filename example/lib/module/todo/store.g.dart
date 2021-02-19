// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// ActionGenerator
// **************************************************************************

mixin _$TodoAction {
  Future<dynamic> _when(
      {@required Future<void> Function(_Add) add,
      @required Future<void> Function(_Del) del,
      @required Future<void> Function(_ClearCompleted) clearCompleted,
      @required Future<void> Function(_Filter) filter,
      @required Future<void> Function(_ToggleComplete) toggleComplete,
      @required Future<void> Function(_ToggleAll) toggleAll,
      @required Future<void> Function(_ChangeName) changeName,
      @required Future<void> Function(_StoreTodos) storeTodos}) {
    if (this is _Add) return add(this);
    if (this is _Del) return del(this);
    if (this is _ClearCompleted) return clearCompleted(this);
    if (this is _Filter) return filter(this);
    if (this is _ToggleComplete) return toggleComplete(this);
    if (this is _ToggleAll) return toggleAll(this);
    if (this is _ChangeName) return changeName(this);
    if (this is _StoreTodos) return storeTodos(this);
    return null;
  }
}

class _Add extends TodoAction {
  final String name;
  const _Add(this.name) : super._();

  @override
  String toString() {
    return 'TodoAction.add(name: $name)';
  }
}

class _Del extends TodoAction {
  final int id;
  const _Del(this.id) : super._();

  @override
  String toString() {
    return 'TodoAction.del(id: $id)';
  }
}

class _ClearCompleted extends TodoAction {
  const _ClearCompleted() : super._();

  @override
  String toString() {
    return 'TodoAction.clearCompleted()';
  }
}

class _Filter extends TodoAction {
  final FilterType filter;
  const _Filter(this.filter) : super._();

  @override
  String toString() {
    return 'TodoAction.filter(filter: $filter)';
  }
}

class _ToggleComplete extends TodoAction {
  final int id;
  const _ToggleComplete(this.id) : super._();

  @override
  String toString() {
    return 'TodoAction.toggleComplete(id: $id)';
  }
}

class _ToggleAll extends TodoAction {
  const _ToggleAll() : super._();

  @override
  String toString() {
    return 'TodoAction.toggleAll()';
  }
}

class _ChangeName extends TodoAction {
  final int id;
  final String name;
  const _ChangeName(this.id, this.name) : super._();

  @override
  String toString() {
    return 'TodoAction.changeName(id: $id, name: $name)';
  }
}

class _StoreTodos extends TodoAction {
  const _StoreTodos() : super._();

  @override
  String toString() {
    return 'TodoAction.storeTodos()';
  }
}

// **************************************************************************
// StateGenerator
// **************************************************************************

mixin _$TodoState {
  FilterType get filter;
  BuiltList<Todo> get todos;

  BuiltList<Todo> get filtered;

  TodoState _copy({FilterType filter, BuiltList<Todo> todos});
}

class _TodoState extends TodoState {
  final FilterType _filter;
  final BuiltList<Todo> _todos;
  BuiltList<Todo> __filtered;
  _TodoState(this._filter, this._todos) : super._();

  @override
  FilterType get filter => _filter;
  @override
  BuiltList<Todo> get todos => _todos;

  @override
  BuiltList<Todo> get filtered {
    if (__filtered == null) {
      __filtered = _filtered;
    }
    return __filtered;
  }

  @override
  TodoState _copy({Object filter = UNSET, Object todos = UNSET}) {
    return _TodoState(filter == UNSET ? _filter : filter as FilterType,
        todos == UNSET ? _todos : todos as BuiltList<Todo>);
  }

  @override
  String toString() {
    return 'TodoState(filter: $filter, todos: $todos)';
  }
}

// **************************************************************************
// ValueGenerator
// **************************************************************************

mixin _$Todo {
  int get id;
  String get name;
  bool get completed;

  Todo copy({int id, String name, bool completed});
}

class _Todo extends Todo {
  final int _id;
  final String _name;
  final bool _completed;

  _Todo(this._id, this._name, this._completed) : super._();

  @override
  int get id => _id;
  @override
  String get name => _name;
  @override
  bool get completed => _completed;

  @override
  Todo copy(
      {Object id = UNSET, Object name = UNSET, Object completed = UNSET}) {
    return _Todo(
        id == UNSET ? _id : id as int,
        name == UNSET ? _name : name as String,
        completed == UNSET ? _completed : completed as bool);
  }

  @override
  String toString() {
    return 'Todo(id: $id, name: $name, completed: $completed)';
  }
}
