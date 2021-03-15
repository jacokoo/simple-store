// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

mixin _$HomePages {
  Widget _when(
      {@required
          Widget Function(_Home) home,
      @required
          Widget Function(_Todo) todo,
      @required
          Widget Function(_NoGenerateTodo) noGenerateTodo,
      @required
          Widget Function(_Inside) inside,
      @required
          Widget Function(_DidUpdate) didUpdate,
      @required
          Widget Function(_DidUpdateModule) didUpdateModule,
      @required
          Widget Function(_DidUpdateModuleBuilder) didUpdateModuleBuilder}) {
    if (this is _Home) return home(this);
    if (this is _Todo) return todo(this);
    if (this is _NoGenerateTodo) return noGenerateTodo(this);
    if (this is _Inside) return inside(this);
    if (this is _DidUpdate) return didUpdate(this);
    if (this is _DidUpdateModule) return didUpdateModule(this);
    if (this is _DidUpdateModuleBuilder) return didUpdateModuleBuilder(this);
    assert(false, 'Unknown page instance: PageGenerator');
    return null;
  }

  bool isType(bool home, bool todo, bool noGenerateTodo, bool inside,
      bool didUpdate, bool didUpdateModule, bool didUpdateModuleBuilder) {
    if (home != null && home && this is _Home) return true;
    if (todo != null && todo && this is _Todo) return true;
    if (noGenerateTodo != null && noGenerateTodo && this is _NoGenerateTodo)
      return true;
    if (inside != null && inside && this is _Inside) return true;
    if (didUpdate != null && didUpdate && this is _DidUpdate) return true;
    if (didUpdateModule != null && didUpdateModule && this is _DidUpdateModule)
      return true;
    if (didUpdateModuleBuilder != null &&
        didUpdateModuleBuilder &&
        this is _DidUpdateModuleBuilder) return true;
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

class _NoGenerateTodo extends HomePages {
  const _NoGenerateTodo() : super._();

  @override
  String get generatedPageName => 'noGenerateTodo';

  @override
  String toString() {
    return 'HomePages.noGenerateTodo()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _NoGenerateTodo);
  }

  @override
  int get hashCode => runtimeType.hashCode;
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

class _DidUpdate extends HomePages {
  const _DidUpdate() : super._();

  @override
  String get generatedPageName => 'didUpdate';

  @override
  String toString() {
    return 'HomePages.didUpdate()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _DidUpdate);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _DidUpdateModule extends HomePages {
  const _DidUpdateModule() : super._();

  @override
  String get generatedPageName => 'didUpdateModule';

  @override
  String toString() {
    return 'HomePages.didUpdateModule()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _DidUpdateModule);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _DidUpdateModuleBuilder extends HomePages {
  const _DidUpdateModuleBuilder() : super._();

  @override
  String get generatedPageName => 'didUpdateModuleBuilder';

  @override
  String toString() {
    return 'HomePages.didUpdateModuleBuilder()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _DidUpdateModuleBuilder);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
