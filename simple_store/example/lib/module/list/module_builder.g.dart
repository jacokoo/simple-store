// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_builder.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

mixin _$ModulePages {
  Widget _when({@required Widget Function(_Detail) detail}) {
    if (this is _Detail) return detail(this);
    assert(false, 'Unknown page instance: PageGenerator');
    return null;
  }

  bool isType(bool detail) {
    if (detail != null && detail && this is _Detail) return true;
    return false;
  }
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
