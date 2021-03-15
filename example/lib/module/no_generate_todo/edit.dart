import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'module.dart';
import 'store.dart';

class TodoEditor extends TodoPage {
    final Todo todo;
    final TextEditingController controller;
    TodoEditor({this.todo}): controller = TextEditingController(text: todo?.name ?? '');

    @override
    String get pageName => todo == null ? 'add' : 'edit';

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('${todo == null ? 'Create Todo' : 'Edit Todo'}'),
                actions: [IconButton(icon: Icon(Icons.check), onPressed: () {
                    final text = controller.text;
                    if (text.isEmpty) return;

                    if (todo == null) {
                        context.dispatch(TodoAction.add(text));
                    } else {
                        context.dispatch(TodoAction.changeName(todo.id, text));
                    }
                    Navigator.of(context).pop(text);
                })],
            ),

            body: body(),
        );
    }

    Widget body() {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    labelText: 'What needs to be done?'
                ),
            )
        );
    }
}
