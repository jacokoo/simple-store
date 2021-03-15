import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'edit.dart';
import 'store.dart';

class TodoContent extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Watch<TodoState>(builder: (ts) {
            final ss = ts.filtered;
            return ListView.separated(
                itemBuilder: (_, idx) => item(context, ss[idx]),
                separatorBuilder: (_, __) => Container(
                    child: Divider(indent: 14, height: 1),
                    color: Colors.white,
                ),
                itemCount: ss.length
            );
        });
    }

    Widget item(BuildContext context, Todo todo) {
        return Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
                Checkbox(value: todo.completed, onChanged: (_) {
                    context.dispatch(TodoAction.toggleComplete(todo.id));
                }),
                Text(todo.name, style: TextStyle(
                    fontSize: 20,
                    color: todo.completed ? Colors.grey : null,
                    decoration: todo.completed ? TextDecoration.lineThrough : null
                )),
                Spacer(),
                IconButton(icon: Icon(Icons.update), onPressed: () async {
                    final re = await context.navTo(TodoEditor(todo: todo));
                    print('navigate result $re');
                }),

                IconButton(icon: Icon(Icons.delete), onPressed: () {
                    context.dispatch(TodoAction.del(todo.id));
                })
            ]),
        );
    }
}
