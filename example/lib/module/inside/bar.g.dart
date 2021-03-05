// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

mixin _$BarPages {
  Widget _when(
      {@required Widget Function(_Bar) bar,
      @required Widget Function(_Bar2) bar2,
      @required Widget Function(_Todo) todo}) {
    if (this is _Bar) return bar(this);
    if (this is _Bar2) return bar2(this);
    if (this is _Todo) return todo(this);
    return null;
  }
}

class _Bar extends BarPages {
  const _Bar() : super._();

  @override
  String get generatedPageName => 'bar';

  @override
  String toString() {
    return 'BarPages.bar()';
  }
}

class _Bar2 extends BarPages {
  const _Bar2() : super._();

  @override
  String get generatedPageName => 'bar2';

  @override
  String toString() {
    return 'BarPages.bar2()';
  }
}

class _Todo extends BarPages {
  const _Todo() : super._();

  @override
  String get generatedPageName => 'todo';

  @override
  String toString() {
    return 'BarPages.todo()';
  }
}
