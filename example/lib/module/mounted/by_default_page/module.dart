import 'package:example/module/mounted/by_default_page/detail.dart';
import 'package:example/module/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

part 'module.g.dart';

@page
abstract class MountedByDefaultPagePages extends SimplePage with _$MountedByDefaultPagePages {
    const MountedByDefaultPagePages._();

    const factory MountedByDefaultPagePages.page() = _Page;
    const factory MountedByDefaultPagePages.detail() = _Detail;
    const factory MountedByDefaultPagePages.todo() = _Todo;
}

class MountedByDefaultPageModule extends Module<MountedByDefaultPagePages> {
    @override
    MountedByDefaultPagePages get defaultPage => MountedByDefaultPagePages.page();

    @override
    Store createStore() => ReadOnlyStore();

    @override
    Widget buildPage(MountedByDefaultPagePages page) => page._when(
        page: (_) => _DefaultPage(),
        detail: (_) => MountedByDefaultPageDetailPage(),
        todo: (_) => TodoModule()
    );
}

class _DefaultPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Column(children: [
            Row(children: [
                TextButton(
                    onPressed: () {
                        context.navTo(MountedByDefaultPagePages.detail());
                    },
                    child: Text('show detail')
                ),
                const SizedBox(width: 10),
                TextButton(
                    onPressed: () {
                        context.navTo(MountedByDefaultPagePages.todo());
                    },
                    child: Text('show todo module')
                ),
            ], mainAxisAlignment: MainAxisAlignment.center),

            const SizedBox(height: 10),

            Text(
                'This module is mounted by provide default page',
                textAlign: TextAlign.center,
            )
        ]);
    }
}
