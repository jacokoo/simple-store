import 'package:built_collection/built_collection.dart';
import 'package:example/module/home/app_list.dart';
import 'package:example/module/home/store.dart';
import 'package:example/module/mounted/mounted.dart';
import 'package:example/module/todo/store.dart';
import 'package:example/module/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

part 'home.g.dart';

@page
abstract class HomePages extends SimplePage with _$HomePages {
    const HomePages._();

    const factory HomePages.home() = _Home;
    const factory HomePages.todo(BuiltList<Todo> todos) = _Todo;
    const factory HomePages.inside() = _Inside;
}

class HomeModule extends Module<HomePages> {
    HomePages get defaultPage => HomePages.home();

    @override
    Widget buildPage(HomePages pages) => pages._when(
        home: (_) => AppListWidget(),
        todo: (p) => TodoModule(),
        inside: (_) => MountedWidget()
    );

    @override
    Store createStore() => HomeStore();
}
