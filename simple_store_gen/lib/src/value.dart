
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:simple_store_base/simple_store_base.dart';
import 'package:simple_store_gen/src/action.dart';
import 'package:simple_store_gen/src/base.dart';
import 'package:simple_store_gen/src/state.dart';

class ValueGenerator extends ValueObjectGenerator<ValueAnnotation> {
    @override
    Future<List<ParameterElement>> validate(ClassElement e, BuildStep step) async {
        checkPrivateConstructor(e, 'value');
        e.ensure(e.constructors.length == 2, 'Value object can have only one factory constructor other than "_"');
        final c = e.constructors.where((ee) => ee.name != '_').first;
        c.ensure(c.isFactory && (c.name == null || c.name.isEmpty) , 'Value object can have only one factory constructor');
        final redirect = await getRedirectConstructor(c, step);
        c.ensure('_${e.name}' == redirect.name, 'redirect constuctor return type must be _${e.name} but got ${redirect.name}');
        final params = c.parameters.where((ee) => ee.isRequiredPositional).toList();
        e.ensure(params.length == c.parameters.length, 'Value object constructor can not have optional or named parameters');
        return params;
    }

    @override
    String get copyName => 'copy';
}
