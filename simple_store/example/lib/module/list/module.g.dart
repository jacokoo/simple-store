// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

mixin _$ModulePages {
  Widget _when(
      {@required Widget Function(_List) list,
      @required Widget Function(_Detail) detail}) {
    if (this is _List) return list(this);
    if (this is _Detail) return detail(this);
    assert(false, 'Unknown page instance: PageGenerator');
    return null;
  }

  bool isType(bool list, bool detail) {
    if (list != null && list && this is _List) return true;
    if (detail != null && detail && this is _Detail) return true;
    return false;
  }
}

class _List extends ModulePages {
  const _List() : super._();

  @override
  String get generatedPageName => 'list';

  @override
  String toString() {
    return 'ModulePages.list()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _List);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class _Detail extends ModulePages {
  const _Detail() : super._();

  @override
  String get generatedPageName => 'detail';

  @override
  String toString() {
    return 'ModulePages.detail()';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Detail);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
