# simple_store

`Simple Store` 是一个 `Flutter` 的单向数据流框架, 负责管理 App 的状态与路由. 将 App 拆分为很多 Module, 每个 Module 都有自己的状态与路由, 使得 App 具有更好的可维护性.

借助于[代码生成(非必须)](), 可以提高框架的约束性, 减少开发过程中犯错的几率.



(起名废求好名字)



## 状态管理

通过 `Widget树` 中包含 `Store` 的节点(Module, Component) 节点将 `Store`(App状态)组成一颗状态树. 

状态记录在不可变的数据对象中, 一个 Store 中可以有多个状态.

子 Store 可以在初始化时引用父 Store (包含先祖)中的状态, 但父 Store 无法访问子 Store 中的状态. 

`Widget` 只能监听当前 Store 的状态, 要监听先祖的状态, 必须在当前 Store 初始化时把状态引用过来.

只能在处理 Action 时修改状态.

一个 Store 只能处理一个类型的 Action(包括子类).

处理 Action 时, 如果当前 Store 不支持该类型的 Action, 只会向上传播(父, 先祖),

当 dispatch 一个 action 时, 不管在 action 处理过程中修改了多少次多少个状态, 监听者(Widget)都只会在 action 处理结束后更新一次.

父 Store 可以向子 Store 广播事件.



## 路由管理

基于 [Flutter Navigator 2.0](navigator) 使用状态管理路由.

路由页面需要在 Module 中定义才能跳转.

Module 是 Widget, 只能路由到加载到 Widget 树中的 Module.

由于页面跳转实际上是 dispatch action, 所以只能跳转到当前 Module 或父 Module 的页面.



## 安装

```yaml
# pubspec.yaml
dependencies:
  simple_store:
```



## API

### SimpleStoreApp

启用simple_store, 初始化 Router

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

### Module

负责创建页面与创建 Store

一个 Module 只能处理一个 SimplePage 类

一个 Module 只会有两层路由: 默认页面, 其它页面中的一个

```dart
// 定义 TodoModule, 指定处理 TodoPages
class TodoModule extends Module<TodoPages> {
  
  // 指定默认页面, 当打开该 Module 时, 默认显示
  @override
  TodoPages get defaultPage => PageTodoList();

  // 为不同的 Page 创建 Widget
  @override
  Widget buildPage(TodoPages pages) {
    if (pages is PageTodoList) return TodoListPage();
    if (pages is PageEditTodo) return TodoEditor(pages.todo);
    // ...
  }

  @override
  // 创建与该 Module 对应的 Store
  Store createStore() => TodoStore();
}
```

#### Navigation

如何跳转页面

```dart
Widget build(BuildContext context, Todo todo) {
  return IconButton(
    icon:..., 
    onPressed: () {
      // 跳转到 PageEditTodo, 返回可以使用 context.pop([result])
      context.navTo(PageEditTodo(todo));
      
      // 如果要获取 pop 时传回来的值, 可以用await
      // await context.navTo(PageEditTodo(todo));
    }
  );
}
```

#### ModuleBuilder

当 Module 加载到 Widget 树上时, 默认使用 defaultPage 对应的 Widget 展示,

可以使用 ModuleBuilder 来用 build 方法提供展示的 Widget.

```Dart
class TodoModule extends Module<TodoPages> with ModuleBuilder {
  // ...
  
  // 通常用于 Module 的入口, 比如点击按钮打开一个 Module.
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text('show todo module'),
      onPressed: () {
        // 打开 PageTodoList 页面
        context.navTo(PageTodoList());
      }
    );
  }
}
```

### Store

记录状态与处理 Action

一个 Store 可以包含多个 State, 但只能处理一个 Action 类.

Store 中的状态通过类型获取, 所以同一个类型在同一个 Store 中只能有一个实例.

如果想要在一个Store中有多个同一类型, 那么必须给每一个实例一个名字.

所有的状态在能被使用前一定要初始化, 否则会报错.

```dart
class TodoStore extends Store<TodoAction> {
  // 初始化 Store 中的 State
  // StoreInitializer.state 用于设置初始化状态: init.state(SomeState())
  // StoreInitializer.ref 用于引用父 Store 中的状态: init.ref<SomeState>()
  @override
  void init(StoreInitializer init) {
  }
  
  // StoreSetter 用于更新 Store 中的状态: set(SomeState())
  // StoreGetter 用于获取 Store 中的状态: get<SomeState>()
  // StoreGetter 还可以用于判断 Store 中是否存在状态: get.has<SomeState>()
  @override
  Future handle(StoreSetter set, StoreGetter get, TodoAction action) async {
    // 处理 Action 时可以用 dispatch 方法调用其它 Action
    dispatch(set, NewAction());
  }
  
  // 当 Store 被销毁时调用
  @override
  void dispose() {
  }
}
```

### Component

Component 是一个用自己 Store 的 Widget

```dart
class SomeComponent extends Component<SomeComponent> {
  // 创建 Store
  @override
  Store createStore() {}
  
  @override
  Widget build(BuildContext context) {}
  
  // 当 update widget 时, 可以向 Store dispatch action
  @override
  void didUpdateWidget(SomeComponent old, Dispatcher dispatch) {}
}
```



### Watch / Get

在 Widget 中使用 Store 中的 State

Watch 会监听 State 的变化, Get 只是获取 build 时的状态, 不会监听

```dart
Widget build(BuildContext context) {
  return Watch<TodoState>(builder: (state) {
    // state.todos
  });
  
  return Get<TodoState>(builder: (state) {
    // state.todos
  });
  
  // Watch 和 Get 都可以最多获取5个不同的状态
  // Watch2<State1, State2>(builder: (state1, state2) {})
  // Get2<State1, State2>(builder: (state1, state2) {})
  // ...
}
```










[navigator]: https://flutter.dev/docs/release/breaking-changes/route-navigator-refactoring