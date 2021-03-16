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
    assert(false, 'Unknown page instance: PageGenerator');
    return null;
  }

  bool isType(bool page, bool detail, bool todo) {
    if (page != null && page && this is _Page) return true;
    if (detail != null && detail && this is _Detail) return true;
    if (todo != null && todo && this is _Todo) return true;
    return false;
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

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Page);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _Detail extends MountedByDefaultPagePages {
  const _Detail() : super._();

  @override
  String get generatedPageName => 'detail';

  @override
  String toString() {
    return 'MountedByDefaultPagePages.detail()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Detail);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _Todo extends MountedByDefaultPagePages {
  const _Todo() : super._();

  @override
  String get generatedPageName => 'todo';

  @override
  String toString() {
    return 'MountedByDefaultPagePages.todo()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Todo);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
