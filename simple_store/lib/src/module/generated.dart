part of '../store.dart';

mixin _$_NavigateAction {
    Future<dynamic> _when({
        @required Future<void> Function(_NavTo) navTo,
        @required Future<void> Function(_Pop) pop
    }) {
        if (this is _NavTo) return navTo(this);
        if (this is _Pop) return pop(this);
        return null;
    }
}

class _NavTo extends _NavigateAction {
    final SimplePage page;
    const _NavTo(this.page): super._();

    @override
    String toString() {
        return '_NavigateAction.push(page: $page)';
    }
}

class _Pop extends _NavigateAction {
    final dynamic result;
    const _Pop(this.result) : super._();

    @override
    String toString() {
        return '_NavigateAction.pop(result: $result)';
    }
}

mixin _$PageState {
    Completer<dynamic> get _completer;
    List<SimplePage> get _stack;
}

class _PageState extends PageState {
    final Completer<dynamic> __completer;
    final List<SimplePage> __stack;
    _PageState(this.__completer, this.__stack) : super._();

    @override
    Completer<dynamic> get _completer => __completer;
    @override
    List<SimplePage> get _stack => __stack;

    @override
    String toString() {
        return 'PageState(_completer: $_completer, _stack: $_stack)';
    }

    @override
    bool operator ==(dynamic o) {
        return identical(o, this) ||
                (o is _PageState && _completer == o._completer && _stack == o._stack);
    }

    @override
    int get hashCode => hashValues(runtimeType, _completer, _stack);
}
