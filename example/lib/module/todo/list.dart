import 'package:example/module/todo/content.dart';
import 'package:example/module/todo/footer.dart';
import 'package:example/module/todo/header.dart';
import 'package:example/module/todo/todo.dart';
import 'package:simple_store/simple_store.dart';
import 'package:flutter/material.dart';

class TodoListPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('TODO'),
                actions: [IconButton(icon: Icon(Icons.add), onPressed: () {
                    context.navigateTo(TodoPages.add());
                })]
            ),
            body: SafeArea(child: Container(child: Column(children: [
                TodoHeader(),
                Divider(height: 1),
                Expanded(child: TodoContent()),
                TodoFooter()
            ]), color: Colors.grey.shade200)),
        );
    }
}
