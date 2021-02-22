import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

part 'foo.g.dart';

@page
abstract class FooPages extends SimplePage with _$FooPages {
    const FooPages._();

    const factory FooPages.foo() = _Foo;
    const factory FooPages.foo2() = _Foo2;
}

class FooModule extends Module<FooPages> {
    @override
    Widget buildPage(ModuleState module, FooPages pages) => pages._when(
        foo: (_) => Center(child: TextButton(child: Text('pop foo2'), onPressed: () {
                module.navTo(FooPages.foo2());
        })),

        foo2: (_) => Scaffold(
            appBar: AppBar(title: Text('foo2')),
            body: Center(child: Text('foo2')),
        )
    );

    @override
    Store<SimpleAction> createStore() => EmptyStore();

    @override
    FooPages get defaultPage => const FooPages.foo();

}
