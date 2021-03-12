// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

mixin _$HomePages {
  Widget _when(
      {@required Widget Function(_Home) home,
      @required Widget Function(_Todo) todo,
      @required Widget Function(_Inside) inside}) {
    if (this is _Home) return home(this);
    if (this is _Todo) return todo(this);
    if (this is _Inside) return inside(this);
    assert(false, 'Unknown page instance: PageGenerator');
    return null;
  }

  bool isType(bool home, bool todo, bool inside) {
    if (home != null && home && this is _Home) return true;
    if (todo != null && todo && this is _Todo) return true;
    if (inside != null && inside && this is _Inside) return true;
    return false;
  }
}

class _Home extends HomePages {
  const _Home() : super._();

  @override
  String get generatedPageName => 'home';

  @override
  String toString() {
    return 'HomePages.home()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Home);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _Todo extends HomePages {
  final BuiltList<Todo> todos;
  const _Todo(this.todos) : super._();

  @override
  String get generatedPageName => 'todo';

  @override
  String toString() {
    return 'HomePages.todo(todos: $todos)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Todo && todos == o.todos);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(todos));
}

class _Inside extends HomePages {
  const _Inside() : super._();

  @override
  String get generatedPageName => 'inside';

  @override
  String toString() {
    return 'HomePages.inside()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Inside);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
