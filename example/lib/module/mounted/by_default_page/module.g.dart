// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

mixin _$MountedByDefaultPagePages {
  Widget _when(
      {@required Widget Function(_Page) page,
      @required Widget Function(_Detail) detail,
      @required Widget Function(_Todo) todo}) {
    if (this is _Page) return page(this);
    if (this is _Detail) return detail(this);
    if (this is _Todo) return todo(this);
    return null;
  }
}

class _Page extends MountedByDefaultPagePages {
  const _Page() : super._();

  @override
  String get generatedPageName => 'page';

  @override
  String toString() {
    return 'MountedByDefaultPagePages.page()';
  }
}

class _Detail extends MountedByDefaultPagePages {
  const _Detail() : super._();

  @override
  String get generatedPageName => 'detail';

  @override
  String toString() {
    return 'MountedByDefaultPagePages.detail()';
  }
}

class _Todo extends MountedByDefaultPagePages {
  const _Todo() : super._();

  @override
  String get generatedPageName => 'todo';

  @override
  String toString() {
    return 'MountedByDefaultPagePages.todo()';
  }
}
