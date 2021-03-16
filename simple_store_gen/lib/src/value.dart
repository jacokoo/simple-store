
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:simple_store_base/simple_store_base.dart';

import 'action.dart';
import 'base.dart';
import 'state.dart';

class ValueGenerator extends ValueObjectGenerator<ValueAnnotation> {
    @override
    Future<List<ParameterElement>> validate(ClassElement e, BuildStep step) async {
        checkPrivateConstructor(e, 'value');
        final cs = e.constructors.where((ee) => ee.isFactory && ee.name == '');
        e.ensure(cs.isNotEmpty, 'Can not find constructor: factory ${e.name}(...)');
        final c = cs.first;
        final redirect = await getRedirectConstructor(c, step);
        c.ensure('_${e.name}' == redirect.name, 'redirect constuctor return type must be _${e.name} but got ${redirect.name}');
        final params = c.parameters.where((ee) => ee.isRequiredPositional).toList();
        e.ensure(params.length == c.parameters.length, 'Value object constructor can not have optional or named parameters');
        return params;
    }

    @override
    String get copyName => 'copy';
}
