import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'store.dart';

part 'module_builder.g.dart';

@page
abstract class ModulePages extends SimplePage with _$ModulePages {
    const ModulePages._();
    const factory ModulePages.detail() = _Detail;
}

class ModuleBuilderDemo extends Module<ModulePages> with ModuleBuilder {
    final int id;
    ModuleBuilderDemo(this.id);

    @override
    ModulePages get defaultPage => ModulePages.detail();

    @override
    Store createStore() => InnerStore(id);

    @override
    Widget buildPage(ModulePages page) => page._when(
        detail: (_) => _DetailPage()
    );

    @override
    void didUpdateWidget(ModuleBuilderDemo widget, Dispatcher dispatch) {
        dispatch(InnerAction.setId(id));
    }

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
