import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'store.dart';

part 'module.g.dart';

@page
abstract class ModulePages extends SimplePage with _$ModulePages {
    const ModulePages._();
    const factory ModulePages.list() = _List;
    const factory ModulePages.detail() = _Detail;
}

class ModuleDemo extends Module<ModulePages> {
    final int id;
    ModuleDemo(this.id);

    @override
    ModulePages get defaultPage => ModulePages.list();

    @override
    Store createStore() => InnerStore(id);

    @override
    Widget buildPage(ModulePages page) => page._when(
        list: (_) => _ListPage(),
        detail: (_) => _DetailPage()
    );

    @override
    void didUpdateWidget(ModuleDemo widget, Dispatcher dispatch) {
        dispatch(InnerAction.setId(id));
    }
}

class _ListPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Watch<InnerState>(builder: (state) => ListTile(
            title: Text(state.name),
            trailing: Icon(Icons.delete),
            onTap: () => context.dispatch(ListAction.delete(state.id))
        ));
    }
}

class _DetailPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(child: Watch<InnerState>(builder: (state) => Text(state.name))),
        );
    }
}
