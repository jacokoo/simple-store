import 'package:built_collection/built_collection.dart';
import 'package:simple_store/simple_store.dart';

import '../todo/store.dart';

part 'store.g.dart';

@action
abstract class HomeAction extends SimpleAction with _$HomeAction {
    const HomeAction._();

    const factory HomeAction.storeTodos(BuiltList<Todo> todos) = _StoreTodos;
}

@state
abstract class TodoStorageState extends SimpleState with _$TodoStorageState {
    TodoStorageState._();

    factory TodoStorageState._create(BuiltList<Todo> todos) = _TodoStorageState;
}

class HomeStore extends Store<HomeAction> {
    @override
    void init(StoreInitializer init) {
        init.transform<PageState>((ps, _) {
            print('page change ${ps.current}');
        });

        init.state(TodoStorageState._create(BuiltList.from([])));
    }

    @override
    Future handle(StoreSetter set, StoreGetter get, HomeAction action) => action._when(
        storeTodos: (p) async {
            set(TodoStorageState._create(p.todos));
        }
    );
}
