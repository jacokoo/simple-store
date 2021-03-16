import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'component.dart';
import 'module.dart';
import 'module_builder.dart';
import 'store.dart';

enum DemoType { Component, Module, ModuleBuilder }

class DidUpdateWidgetDemo extends Component<DidUpdateWidgetDemo> {
    final DemoType type;
    DidUpdateWidgetDemo(this.type);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Did update widget demo')),
            body: body(),
        );
    }

    Widget body() {
        return Watch<ListState>(builder: (state) => ListView.separated(
            itemBuilder: (_, idx) => content(state.items[idx].id),
            separatorBuilder: (_, __) => Divider(indent: 14, height: 1),
            itemCount: state.items.length
        ));
    }

    Widget content(int id) {
        if (type == DemoType.Component) {
            return ComponentDemo(id);
        }

        if (type == DemoType.Module) {
            return ModuleDemo(id);
        }

        if (type == DemoType.ModuleBuilder) {
            return ModuleBuilderDemo(id);
        }

        return null;
    }

    @override
    Store<SimpleAction> createStore() => ListStore();
}
