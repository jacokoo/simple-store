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
      @required Future<void> Function(_ChangeName) changeName}) {
    if (this is _Add) return add(this);
    if (this is _Del) return del(this);
    if (this is _ClearCompleted) return clearCompleted(this);
    if (this is _Filter) return filter(this);
    if (this is _ToggleComplete) return toggleComplete(this);
    if (this is _ToggleAll) return toggleAll(this);
    if (this is _ChangeName) return changeName(this);
    assert(false, 'Unknown action instance: ActionGenerator');
    return null;
  }

  bool isType(bool add, bool del, bool clearCompleted, bool filter,
      bool toggleComplete, bool toggleAll, bool changeName) {
    if (add != null && add && this is _Add) return true;
    if (del != null && del && this is _Del) return true;
    if (clearCompleted != null && clearCompleted && this is _ClearCompleted)
      return true;
    if (filter != null && filter && this is _Filter) return true;
    if (toggleComplete != null && toggleComplete && this is _ToggleComplete)
      return true;
    if (toggleAll != null && toggleAll && this is _ToggleAll) return true;
    if (changeName != null && changeName && this is _ChangeName) return true;
    return false;
  }
}

class _Add extends TodoAction {
  final String name;
  const _Add(this.name) : super._();

  @override
  String toString() {
    return 'TodoAction.add(name: $name)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Add && name == o.name);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(name));
}

class _Del extends TodoAction {
  final int id;
  const _Del(this.id) : super._();

  @override
  String toString() {
    return 'TodoAction.del(id: $id)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Del && id == o.id);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(id));
}

class _ClearCompleted extends TodoAction {
  const _ClearCompleted() : super._();

  @override
  String toString() {
    return 'TodoAction.clearCompleted()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _ClearCompleted);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _Filter extends TodoAction {
  final FilterType filter;
  const _Filter(this.filter) : super._();

  @override
  String toString() {
    return 'TodoAction.filter(filter: $filter)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Filter && filter == o.filter);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(filter));
}

class _ToggleComplete extends TodoAction {
  final int id;
  const _ToggleComplete(this.id) : super._();

  @override
  String toString() {
    return 'TodoAction.toggleComplete(id: $id)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _ToggleComplete && id == o.id);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(id));
}

class _ToggleAll extends TodoAction {
  const _ToggleAll() : super._();

  @override
  String toString() {
    return 'TodoAction.toggleAll()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _ToggleAll);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _ChangeName extends TodoAction {
  final int id;
  final String name;
  const _ChangeName(this.id, this.name) : super._();

  @override
  String toString() {
    return 'TodoAction.changeName(id: $id, name: $name)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) ||
        (o is _ChangeName && id == o.id && name == o.name);
  }

  @override
  int get hashCode =>
      hashValues(runtimeType, toHashValue(id), toHashValue(name));
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

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) ||
        (o is _TodoState && filter == o.filter && todos == o.todos);
  }

  @override
  int get hashCode =>
      hashValues(runtimeType, toHashValue(filter), toHashValue(todos));
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

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) ||
        (o is _Todo &&
            id == o.id &&
            name == o.name &&
            completed == o.completed);
  }

  @override
  int get hashCode => hashValues(
      runtimeType, toHashValue(id), toHashValue(name), toHashValue(completed));
}
