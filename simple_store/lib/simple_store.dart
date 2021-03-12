library simple_store;

import 'package:flutter/material.dart';

export 'package:simple_store_base/simple_store_base.dart';
export 'src/store.dart';
export 'package:flutter/material.dart' show Widget, hashValues, hashList;
export 'dart:core' show identical;

Object toHashValue(Object o) => o is Iterable ? hashList(o) : o;
