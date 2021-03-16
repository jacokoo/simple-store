import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

import 'store.dart';

class ComponentDemo extends Component<ComponentDemo> {
    final int id;
    ComponentDemo(this.id);

    @override
    Widget build(BuildContext context) {
        return Watch<InnerState>(builder: (state) => ListTile(
            title: Text('${state.name}'),
            trailing: Icon(Icons.delete),
            onTap: () {
                context.dispatch(ListAction.delete(state.id));
            },
        ));
    }

    @override
    Store<SimpleAction> createStore() => InnerStore(id);

    @override
    void didUpdateWidget(covariant ComponentDemo old, dispatch) {
        dispatch(InnerAction.setId(id));
    }
}
