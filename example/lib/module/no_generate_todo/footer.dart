import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'store.dart';

class TodoFooter extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Watch<TodoState>(builder: (ts) {
                final count = ts.todos.where((e) => !e.completed).length;
                return Row(children: [
                    Text('$count ${count == 1 ? 'item' : 'items'} left'),
                    Spacer(),
                    TextButton(onPressed: () {
                        context.dispatch(ActionClearCompletedTodos());
                    }, child: Text('Clear Completed'))
                ]);
            }),
        );
    }
}
