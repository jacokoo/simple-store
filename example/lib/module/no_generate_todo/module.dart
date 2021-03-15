import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'list.dart';
import 'store.dart';

abstract class TodoPage extends CommonPage {}

abstract class CommonPage extends SimplePage {
    @override
    String get generatedPageName => pageName;

    String get pageName;

    Widget build(BuildContext context);
}

abstract class CommonModule<T extends SimplePage> extends Module<T> {
    @override
    bool isSamePage(T t1, T t2) => t1.generatedPageName == t2.generatedPageName;
}

class NoGenerateTodoModule extends CommonModule<TodoPage> {
    @override
    // context is not required
    Widget buildPage(TodoPage page) => Builder(builder: (context) => page.build(context));

    @override
    Store<SimpleAction> createStore() => TodoStore();

    @override
    TodoPage get defaultPage => TodoListPage();
}
