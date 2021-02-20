# Simple Store

`Simple Store` 是一个 `Flutter` 的单向数据流框架, 负责管理 App 的状态与路由.

(起名废求好名字)



## 安装

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  simple_store:

dev_dependencies:
  build_runner:
  simple_store_gen:
```



### 运行build runner

```bash
dart pub run build_runner watch
```

需要生成代码(@action, @state, @value, @page 有这几个标签类)的文件中需要加上`part`指令

如果当前文件为 `store.dart`

那么需要在文件中加入这一行:

```dart
import 'package:simple_store/simple_store.dart';

part 'store.g.dart';
```



## 状态管理

通过 `Widget树` 中的 `Module`,`Component` 节点将 `Store`(App状态)组成一颗状态树. 

子 Store 可以在初始化时引用父 Store (包含先祖)中的状态, 但父 Store 无法访问子 Store 中的状态. 

父 Store 可以向子 Store 广播事件.

`Widget` 只能监听当前 Store 的状态, 要监听先祖的状态, 必须在当前 Store初始化时把状态引用过来.

定义状态时只能有私有的构造函数与只读属性(`Dart`的代码生成), 使得改变状态只能发生在定义该状态的 Store 的 Action 中进行. 

强类型的 Action(`Dart`的代码生成), 私有的处理方法, 使得 Action 的处理只能在定义该 Action 的 Store 中进行.

当 dispatch 一个 action 时, 不管在 action 处理过程中修改了多少次多少个状态, 监听者都只会在 action 处理结束后更新一次.



### State

State 为只读对象, 创建 State 只能由 `_create` 构造函数与`_copy`方法:

所有的 State 必须继承 `SimpleState`

P.S. 可以使用`VS Code` 的 [Snippet](snippet) 快速创建 State

```dart
// 定义 TodoState
// 必须是抽象类, 具体实现类将自动生成
@state
abstract class TodoState extends SimpleState with _$TodoState {
  // 私有的默认构造函数, 为了使该类能被继承
  TodoState._();
  
  // 私有的 _create 构造函数, 所以必须与处理它的 Store 定义在同一个文件中
  // 定义该 State 中包含的数据, filter 与 todos
  factory TodoState._create(FilterType filter, BuiltList<Todo> todos) = _TodoState;
  
  // getter 缓存
  // 私有的 getter 方法将生成新的公有 getter, 并将私有 getter 的返回值缓存起来
  // 这里将会生成 BuiltList<Todo> get filtered
  // 由于结果被缓存, 如果属性值变化无法被感知, 所以使用时应注意 State 中的属性都要是不可变对象
  // 实体可以用自带的 Value 来定义, 集合可以用 dart 官方的 built_collection 或 kt.dart 库
  BuiltList<Todo> get _filtered {
    if (filter == FilterType.All) return todos;
    if (filter == FilterType.Active) return todos.where((e) => !e.completed).toBuiltList();
    return todos.where((e) => e.completed).toBuiltList();
  }
}

final state = TodoState._create(FilterType.All, []);

// 读取 state 的 filter 属性
assert(state.filter == FilterType.All);

// 读取 state 的 todos 属性
assert(state.todos.isEmpty);

// 由 _filtered 方法生成的公有 getter
// 将会在第一次调用的时候把 _filtered 的返回值缓存起来
state.filtered

// 创建新的State
// 复制除了指定属性外的所有其它属性
final newState = state._copy(filter: FilterType.Active);
```



### Action

一个 Store 只能处理一个 Action 类, 一个 Action 类中可以包含多个 Action(通过不同的带名字的常量工厂构造函数).

所有的 Action 必须继承 `SimpleAction`

P.S. 可以使用`VS Code` 的 [Snippet](snippet) 快速创建 Action

```dart
// 定义 TodoAction
// 必须是抽象类, 具体实现类将自动生成
@action
abstract class TodoAction extends SimpleAction with _$TodoAction {
  // 私有的默认构造函数, 为了使该类能被继承 
  const TodoAction._();

  // 定义具体的强类型 Action
  // 由于是强类型, 所以在 dispatch action 和处理 action 的时候可以有类型校验, 防止传错数据
  // 返回类型必须是私有的(如: _Add, _Del), 所以只有在定义该类的文件中才能判断是哪个 action
  const factory TodoAction.add(String name) = _Add;
  
  // 返回类型可以带一个泛型, 用于指定 action 处理时的返回值类型
  const factory TodoAction.del(int id) = _Del<int>;
  const factory TodoAction.clearCompleted() = _ClearCompleted;
  const factory TodoAction.filter(FilterType filter) = _Filter;
  const factory TodoAction.toggleComplete(int id) = _ToggleComplete;
  const factory TodoAction.toggleAll() = _ToggleAll;
  const factory TodoAction.changeName(int id, String name) = _ChangeName;

  const factory TodoAction.storeTodos() = _StoreTodos;
}

// 创建 action, 由于是公有的构造函数, 所以可以在任何地方实例化
final action = const TodoAction.add('hello');

// 处理 action,
// 所有的处理函数都是 async 的 
action._when(
  
  // 匹配 TodoAction.add
  add: (p) async {
    // p.name 获取 action 传的值
    assert(p.name == 'hello');
  },

  // 匹配 TodoAction.del
  // 由于当前 action 是 TodoAction.add, 所以不会调这个方法
  del: (p) async {
    // 由于定义 del 时带了 int 返回值, 所以这里必须返回一个 int 类型数据
    return p.id;
  },
  
  clearCompleted: (_) async {
    assert(false, 'will not reach here');
  },
  // ...
  // 其它 action 处理
)

```




### Store

记录状态与处理 Action

一个 Store 可以包含多个 State, 但只能处理一个 Action 类.

Store 中的状态通过类型获取, 所以同一个类型在同一个 Store 中只能有一个实例.

如果想要在一个Store中有多个同一类型, 那么必须给每一个实例一个名字.

所有的状态在能被使用前一定要初始化, 否则会报错.

`Widget` 只能监听当前 Store 的状态, 但 Action 会一直往父节点走, 直到找到能处理的 Store 或 报处理不了的异常

```dart
// 定义 TodoStore
// 指定处理的 Action 类为 TodoAction
class TodoStore extends Store<TodoAction> {
  @override
  // 初始化 Store 中的 State
  void init(StoreInitializer init) {
    
    // ref: 引用父 Store 中的状态
    // 可选参数 setter 可以把父 Store 中的状态转化成自己想要的类型
    // 如果不提供 setter 参数, 则直接把父 Store 中的状态设置到本 Store 中
    init.ref<TodoStorageState>(setter: (hs, set) {
      set(TodoState._create(FilterType.All, hs.todos));
    });
    
    // 初始化 state
    // 并将 TodoState 命名为 foo
    // name 为可选参数, 如果只需要一个实例, 就不用命名
    init.state(TodoState._create(FilterType.Active, BuiltList.from([])), name: 'foo');
    
    // 为命名的 State 提供初始化方法
    // 当 Store 中不存在名字为 name 的 TodoState, 将调用该方法来初始化
    init.namedState<TodoState>((name) => TodoState._create(FilterType.All, BuiltList.from([])));
    
    // 定义事件
    // 可以被子孙 Store 监听
    init.event<TodoState>();
    
    // 监听先祖事件
    init.listen<TodoState>(listener: (ts) {
      // dispatch(null, SomeAction);
    });
  }

  @override
  // 处理 Action
  Future handle(StoreSetter set, StoreGetter get, TodoAction action) => action._when(
    add: (p) async {
      // 使用 get 从当前 Store 中获取状态
      final state = get<TodoState>();
      final todo = Todo(id ++, p.name, false);
      
      // 使用 set 更新状态.
      set(state._copy(todos: state.todos.rebuild((list) => list.add(todo))));
    },
    
    // ...
    // 其它 action 类型
  );
)
```



### Value

value 用于定义只读实体类.

P.S. 可以使用`VS Code` 的 [Snippet](snippet) 快速创建 Action

```dart
// Value 的定义与 State 基本一样
// 区别在于 Value 有公有构造函数, 与公有的 copy 方法
@value
abstract class Todo with _$Todo {
  Todo._();

  factory Todo(int id, String name, bool completed) = _Todo;
}
```



### Dispatch

可以在两个地方调用 dispatch 方法:

* BuildContext.dispatch(SimpleAction) 用于 Widget 中调用
* Store.dispatch(StoreSetter, SimpleAction) 用于 Store 内部调用

区别在于 StoreSetter

StoreSetter 用于修改 Store 状态并收集变更信息, 在 dispatch 完成的时候再通知监听者状态变更,

如果 StoreSetter 为 null, 那么则会创建一个新的 StoreSetter, 每创建一个 StoreSetter 会导致一次通知监听者状态变更.

所以在`Widget`中调用 dispatch 时, StoreSetter 传的是 null, 确保监听者会收到一次状态变更通知,

而在 Store 中调用 dispatch 时, 可以根据需要是否使用当前的 StoreSetter.



## 路由管理

之所以在本库中管理路由, 原因有三点:

1. Flutter 的 Navigator 太过于随意, 不利于控制项目结构;

2. Flutter 的 Navigator 2.0 中使用 Router 来管理路由, 页面转换使用状态来控制;

3. 由于 Store 是根据 `Widget` 树来组织结构的, 而路由会打破正常的 Widget 树结构(新 push 的页面不是调用 push 的 widget 的子节点), 从而导致 Store 的树错乱.

   ```dart
   class Foo extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return TextButton(child: Text('push'), onPress: () {
         Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
           // 如果直接 return bar 会导致 Bar 拿到的 Store 与 Foo 拿到的 Store 不是同一个
           return Bar();
           
           // 需要把当前 context 中的 Store 转过去, 才能正常访问
           // 虽然可以解决, 但这使的路由变的过于复杂
           return StoreRedirector(context: context, () => Bar());
         }));
       });
     }
   }
   ```
   
   

### SimpleStoreApp

根结点, 用于初始化 Router

```dart
void main() {
  runApp(SimpleStoreApp(
    // home 页面, 可以是任意 Widget
    home: MyApp(),
    
    // 使用 MaterialApp.router 构造 MaterialApp, 来启用 Router
    builder: (delegate, parser) => MaterialApp.router(
      routeInformationParser: parser, routerDelegate: delegate
    ),
  ));
}
```



### Page

用于定义一个 Module 中的页面, 使用方法跟 Action 一样

P.S. 可以使用`VS Code` 的 [Snippet](snippet) 快速创建 Page

```dart
@page
abstract class TodoPages extends SimplePage with _$TodoPages {
  const TodoPages._();

  const factory TodoPages.list() = _ListPage;
  const factory TodoPages.add() = _AddPage;
  const factory TodoPages.edit(Todo todo) = _EditPage;
}
```



### Module

负责创建页面与创建 Store

一个 Module 只能处理一个 SimplePage 类

一个 Module 只会有两层路由: 默认页面, 其它页面中的一个

```dart
// 定义 TodoModule, 指定处理 TodoPages
class TodoModule extends Module<TodoPages> {
  @override
  // 指定默认页面, 当打开该 Module 时, 默认显示
  TodoPages get defaultPage => TodoPages.list();

  @override
  // 为不同的 Page 创建 Widget
  // ModuleState 用于路由: nav.to(TodoPages.add()) 或 nav.pop(result)
  // 
  // 如果当前的路由栈是: [list, edit], 那么调用 nav.to(TodoPages.add()) 后,
  // 栈会变成 [list, add] 而不是 [list, edit, add]
  //
  // 如果当前的路由栈是: [list, edit], 那么调用 nav.to(TodoPages.list()) 后,
  // 栈会变成 [list] 而不是 [list, edit, list]
  Widget buildPage(ModuleState nav, TodoPages pages) => pages._when(
    list: (_) => TodoListPage(),
    add: (_) => TodoEditor(),
    edit: (s) => TodoEditor(todo: s.todo)
  );

  @override
  // 创建与该 Module 对应的 Store
  Store createStore() => TodoStore();

  // 当该 Module dispose 的时候, 会 dispatch 这些 Action
  List<SimpleAction> get disposeActions => [TodoAction.storeTodos()];
  
  // 当该 Module 初始化的时候, 会 dispatch 这些 Action
  // List<SimpleAction> get initActions => [TodoAction.storeTodos()];
}
```


[snippet]: https://github.com/jacokoo/simple-store/blob/master/snippets.json
