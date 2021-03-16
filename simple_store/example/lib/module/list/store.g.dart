// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// ActionGenerator
// **************************************************************************

mixin _$ListAction {
  Future<dynamic> _when({@required Future<void> Function(_Delete) delete}) {
    if (this is _Delete) return delete(this);
    assert(false, 'Unknown action instance: ActionGenerator');
    return null;
  }

  bool isType(bool delete) {
    if (delete != null && delete && this is _Delete) return true;
    return false;
  }
}

class _Delete extends ListAction {
  final int id;
  const _Delete(this.id) : super._();

  @override
  String toString() {
    return 'ListAction.delete(id: $id)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Delete && id == o.id);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(id));
}

mixin _$InnerAction {
  Future<dynamic> _when({@required Future<void> Function(_SetId) setId}) {
    if (this is _SetId) return setId(this);
    assert(false, 'Unknown action instance: ActionGenerator');
    return null;
  }

  bool isType(bool setId) {
    if (setId != null && setId && this is _SetId) return true;
    return false;
  }
}

class _SetId extends InnerAction {
  final int id;
  const _SetId(this.id) : super._();

  @override
  String toString() {
    return 'InnerAction.setId(id: $id)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _SetId && id == o.id);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(id));
}

// **************************************************************************
// StateGenerator
// **************************************************************************

mixin _$ListState {
  BuiltList<Item> get items;

  ListState _copy({BuiltList<Item> items});
}

class _ListState extends ListState {
  final BuiltList<Item> _items;

  _ListState(this._items) : super._();

  @override
  BuiltList<Item> get items => _items;

  @override
  ListState _copy({Object items = UNSET}) {
    return _ListState(items == UNSET ? _items : items as BuiltList<Item>);
  }

  @override
  String toString() {
    return 'ListState(items: $items)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _ListState && items == o.items);
  }

  @override
  int get hashCode => hashValues(runtimeType, toHashValue(items));
}

mixin _$InnerState {
  int get id;
  String get name;

  InnerState _copy({int id, String name});
}

class _InnerState extends InnerState {
  final int _id;
  final String _name;

  _InnerState(this._id, this._name) : super._();

  @override
  int get id => _id;
  @override
  String get name => _name;

  @override
  InnerState _copy({Object id = UNSET, Object name = UNSET}) {
    return _InnerState(
        id == UNSET ? _id : id as int, name == UNSET ? _name : name as String);
  }

  @override
  String toString() {
    return 'InnerState(id: $id, name: $name)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) ||
        (o is _InnerState && id == o.id && name == o.name);
  }

  @override
  int get hashCode =>
      hashValues(runtimeType, toHashValue(id), toHashValue(name));
}

// **************************************************************************
// ValueGenerator
// **************************************************************************

mixin _$Item {
  int get id;
  String get name;

  Item copy({int id, String name});
}

class _Item extends Item {
  final int _id;
  final String _name;

  _Item(this._id, this._name) : super._();

  @override
  int get id => _id;
  @override
  String get name => _name;

  @override
  Item copy({Object id = UNSET, Object name = UNSET}) {
    return _Item(
        id == UNSET ? _id : id as int, name == UNSET ? _name : name as String);
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name)';
  }

  @override
  bool operator ==(dynamic o) {
    return identical(o, this) || (o is _Item && id == o.id && name == o.name);
  }

  @override
  int get hashCode =>
      hashValues(runtimeType, toHashValue(id), toHashValue(name));
}
