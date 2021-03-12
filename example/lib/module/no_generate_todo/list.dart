import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'content.dart';
import 'edit.dart';
import 'footer.dart';
import 'header.dart';
import 'module.dart';

class TodoListPage extends TodoPage {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('TODO'),
                actions: [IconButton(icon: Icon(Icons.add), onPressed: () {
                    context.navTo(TodoEditor());
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

    @override
    bool operator ==(dynamic o) {
        return identical(o, this) || (o is TodoListPage);
    }

    @override
    int get hashCode => runtimeType.hashCode;
}
