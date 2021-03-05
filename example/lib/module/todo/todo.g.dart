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
    return null;
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
}

class _AddPage extends TodoPages {
  const _AddPage() : super._();

  @override
  String get generatedPageName => 'add';

  @override
  String toString() {
    return 'TodoPages.add()';
  }
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
}
