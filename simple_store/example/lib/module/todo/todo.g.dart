// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

mixin _$TodoPages {
  Widget _when(
      {@required Widget Function(_ListPage) list,
      @required Widget Function(_AddPage) add,
      @required Widget Function(_EditPage) edit}) {
    if (this is _ListPage) return list(this);
    if (this is _AddPage) return add(this);
    if (this is _EditPage) return edit(this);
    assert(false, 'Unknown page instance: PageGenerator');
    return null;
  }

  bool isType(bool list, bool add, bool edit) {
    if (list != null && list && this is _ListPage) return true;
    if (add != null && add && this is _AddPage) return true;
    if (edit != null && edit && this is _EditPage) return true;
    return false;
  }
}

class _ListPage extends TodoPages {
  const _ListPage() : super._();

  @override
  String get generatedPageName => 'list';

  @override
  String toString() {
    return 'TodoPages.list()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _ListPage);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _AddPage extends TodoPages {
  const _AddPage() : super._();

  @override
  String get generatedPageName => 'add';

  @override
  String toString() {
    return 'TodoPages.add()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _AddPage);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _EditPage extends TodoPages {
  final Todo todo;
  const _EditPage(this.todo) : super._();

  @override
  String get generatedPageName => 'edit';

  @override
  String toString() {
    return 'TodoPages.edit(todo: $todo)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _EditPage && todo == o.todo);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(todo));
}
