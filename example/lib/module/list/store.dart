import 'package:built_collection/built_collection.dart';
import 'package:simple_store/simple_store.dart';

part 'store.g.dart';

@value
abstract class Item with _$Item {
    Item._();
    factory Item(int id, String name) = _Item;
}

@state
abstract class ListState extends SimpleState with _$ListState {
    ListState._();
    factory ListState._create(BuiltList<Item> items) = _ListState;
}

@action
abstract class ListAction extends SimpleAction with _$ListAction {
    const ListAction._();

    const factory ListAction.delete(int id) = _Delete;
}

class ListStore extends Store<ListAction> {
    @override
    void init(StoreInitializer init) {
        init.state(ListState._create(List.generate(10, (index) => Item(index, 'Item $index')).toBuiltList()));
    }

    @override
    Future handle(StoreSetter set, StoreGetter get, ListAction action) => action._when(
        delete: (payload) async {
            final state = get<ListState>();
            set(state._copy(items: state.items.where((i) => i.id != payload.id).toBuiltList()));
        }
    );
}

@state
abstract class InnerState extends SimpleState with _$InnerState {
    InnerState._();
    factory InnerState._create(int id, String name) = _InnerState;
}

@action
abstract class InnerAction extends SimpleAction with _$InnerAction {
    const InnerAction._();
    const factory InnerAction.setId(int id) = _SetId;
}

class InnerStore extends Store<InnerAction> {
    int id;
    InnerStore(this.id);

    @override
    void init(StoreInitializer init) {
        init.state(InnerState._create(0, ''));
        init.ref<ListState>();

        dispatch(null, InnerAction.setId(id));
    }

    @override
    Future handle(StoreSetter set, StoreGetter get, InnerAction action) => action._when(
        setId: (p) async {
            id = p.id;
            final state = get<ListState>();
            final item = state.items.where((i) => i.id == id).toList();
            if (item.isNotEmpty) {
                set(InnerState._create(item[0].id, item[0].name));
            }
        }
    );
}
