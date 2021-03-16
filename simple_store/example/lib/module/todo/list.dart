import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'content.dart';
import 'footer.dart';
import 'header.dart';
import 'todo.dart';

class TodoListPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('TODO'),
                actions: [IconButton(icon: Icon(Icons.add), onPressed: () {
                    context.navTo(TodoPages.add());
                })]
            ),
            body: SafeArea(child: Container(
                color: Colors.grey.shade200,
                child: Column(children: [
                    TodoHeader(),
                    Divider(height: 1),
                    Expanded(child: TodoContent()),
                    TodoFooter()
                ]),
            )),
        );
    }
}
