import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'detail.dart';

part 'module.g.dart';

@page
abstract class MountedByBuildMethodPages extends SimplePage with _$MountedByBuildMethodPages {
    const MountedByBuildMethodPages._();
    const factory MountedByBuildMethodPages.page() = _Page;
}

class MountedByBuildMethodModule extends Module<MountedByBuildMethodPages> with ModuleBuilder {
    @override
    Store createStore() => ReadOnlyStore('$runtimeType');

    @override
    Widget buildPage(MountedByBuildMethodPages page) => page._when(
        page: (_) => MountedByBuildMethodDetailPage()
    );

    @override
    Widget build(BuildContext context) {
        return Column(children: [
            TextButton(
                onPressed: () {
                    context.navTo(MountedByBuildMethodPages.page());
                },
                child: Text('show detail')
            ),

            const SizedBox(height: 10),

            Text(
                'This module is mounted by override the build method',
                textAlign: TextAlign.center,
            )
        ]);
    }
}
