import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'list.dart';
import 'store.dart';

abstract class TodoPage extends CommonPage {}

abstract class CommonPage extends SimplePage {
    @override
    String get generatedPageName => 'common-page';

    Widget build(BuildContext context);
}

class NoGenerateTodoModule extends Module<TodoPage> {
    @override
    // context is not required
    Widget buildPage(TodoPage page) => Builder(builder: (context) => page.build(context));

    @override
    Store<SimpleAction> createStore() => TodoStore();

    @override
    TodoPage get defaultPage => TodoListPage();
}
