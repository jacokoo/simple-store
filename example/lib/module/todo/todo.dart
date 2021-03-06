import 'package:example/module/todo/edit.dart';
import 'package:example/module/todo/list.dart';
import 'package:example/module/todo/store.dart';
import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

part 'todo.g.dart';

@page
abstract class TodoPages extends SimplePage with _$TodoPages {
    const TodoPages._();

    const factory TodoPages.list() = _ListPage;
    const factory TodoPages.add() = _AddPage;
    const factory TodoPages.edit(Todo todo) = _EditPage;
}

class TodoModule extends Module<TodoPages> {
    @override
    TodoPages get defaultPage => TodoPages.list();

    @override
    Widget buildPage(ModuleState _, TodoPages pages) => pages._when(
        list: (_) => TodoListPage(),
        add: (_) => TodoEditor(),
        edit: (s) => TodoEditor(todo: s.todo)
    );

    @override
    Store createStore() => TodoStore();
}
