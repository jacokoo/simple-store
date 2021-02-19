import 'package:example/module/todo/store.dart';
import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

class TodoHeader extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Watch<TodoState>(builder: (ts) => Row(children: [
                TextButton(onPressed: () {
                    context.dispatch(TodoAction.toggleAll());
                }, child: Text('Toggle All')),
                Spacer(),
                filter(ts, 'All', FilterType.All, context),
                filter(ts, 'Active', FilterType.Active, context),
                filter(ts, 'Completed', FilterType.Completed, context),
            ])),
        );
    }

    Widget filter(TodoState ts, String name, FilterType type, BuildContext context) {
        return Container(
            child: TextButton(
                child: Text(name, style: TextStyle(color: ts.filter == type ? Colors.red : null)),
                onPressed: () {
                    context.dispatch(TodoAction.filter(type));
                },
            ),
        );
    }
}
