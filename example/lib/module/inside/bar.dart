import 'package:example/module/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

part 'bar.g.dart';

@page
abstract class BarPages extends SimplePage with _$BarPages {
    const BarPages._();

    const factory BarPages.bar() = _Bar;
    const factory BarPages.bar2() = _Bar2;
    const factory BarPages.todo() = _Todo;
}

class BarModule extends Module<BarPages> {
    @override
    Widget buildPage(ModuleState nav, BarPages pages) => pages._when(
        bar: (_) => Center(child: Column(children: [
            TextButton(child: Text('pop bar2'), onPressed: () {
                nav.to(BarPages.bar2());
            }),
            TextButton(child: Text('pop todo'), onPressed: () {
                nav.to(BarPages.todo());
            })
        ])),

        bar2: (_) => Scaffold(
            appBar: AppBar(title: Text('bar2')),
            body: Center(child: Text('bar2')),
        ),

        todo: (_) => TodoModule()
    );

    @override
    Store<SimpleAction> createStore() => EmptyStore();

    @override
    BarPages get defaultPage => BarPages.bar();

}
