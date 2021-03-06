import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'home.dart';
import 'store.dart';

class AppListWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Examples')),
            body: SafeArea(child: body(context)),
        );
    }

    Widget body(BuildContext context) => ListView(
        children: [
            Watch<TodoStorageState>(builder: (hs) => ListTile(
                title: Text('Todo App'),
                subtitle: Text('Have ${hs.todos.length} todos'),
                onTap: () {
                    context.navTo(HomePages.todo(hs.todos));
                },
            )),
            Divider(height: 1, indent: 14),
            ListTile(
                title: Text('Todo App - No Generated Code'),
                onTap: () {
                    context.navTo(HomePages.noGenerateTodo());
                },
            ),
            Divider(height: 1, indent: 14),
            ListTile(
                title: Text('Mounted Module'),
                onTap: () {
                    context.navTo(HomePages.inside());
                },
            ),
            Divider(height: 1, indent: 14),
            ListTile(
                title: Text('Did Update Widget Demo - Component'),
                onTap: () {
                    context.navTo(HomePages.didUpdate());
                },
            ),
            Divider(height: 1, indent: 14),
            ListTile(
                title: Text('Did Update Widget Demo - Module'),
                subtitle: Text('Use default page'),
                onTap: () {
                    context.navTo(HomePages.didUpdateModule());
                },
            ),
            Divider(height: 1, indent: 14),
            ListTile(
                title: Text('Did Update Widget Demo - Module'),
                subtitle: Text('Use ModuleBuilder'),
                onTap: () {
                    context.navTo(HomePages.didUpdateModuleBuilder());
                },
            ),
        ],
    );
}
