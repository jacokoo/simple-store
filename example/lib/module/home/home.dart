import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import '../mounted/mounted.dart';
import '../no_generate_todo/module.dart';
import '../todo/store.dart';
import '../todo/todo.dart';
import 'app_list.dart';
import 'store.dart';

part 'home.g.dart';

@page
abstract class HomePages extends SimplePage with _$HomePages {
    const HomePages._();

    const factory HomePages.home() = _Home;
    const factory HomePages.todo(BuiltList<Todo> todos) = _Todo;
    const factory HomePages.noGenerateTodo() = _NoGenerateTodo;
    const factory HomePages.inside() = _Inside;
}

class HomeModule extends Module<HomePages> {
    HomePages get defaultPage => HomePages.home();

    @override
    Widget buildPage(HomePages pages) => pages._when(
        home: (_) => AppListWidget(),
        todo: (p) => TodoModule(),
        inside: (_) => MountedWidget(),
        noGenerateTodo: (_) => NoGenerateTodoModule()
    );

    @override
    Store createStore() => HomeStore();
}
