import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:simple_store_gen/src/action.dart';
import 'package:simple_store_gen/src/base.dart';
import 'package:simple_store_base/simple_store_base.dart';

abstract class ValueObjectGenerator<T> extends BaseGenerator<T> {
    @override
    Future<List<String>> doGenerate(ClassElement e, BuildStep step) async {
        final params = await validate(e, step);
        final caches = e.fields.where((ee) => ee.name.startsWith('_')).toList();
        return [generateMixin(e.name, params, caches), generateSub(e.name, params, caches)];
    }

    Future<List<ParameterElement>> validate(ClassElement e, BuildStep step);

    String generateMixin(String name, List<ParameterElement> params, List<FieldElement> fes) {
        final fields = params.map((e) => '${e.typeName} get ${e.name};').join('\n');
        final ps = params.map((e) => '${e.typeName} ${e.name}').join(', ');
        final caches = fes.map((e) => '${e.typeName} get ${e.name.substring(1)};').join('\n');

        return '''
        mixin _\$$name {
            $fields

            $caches

            $name $copyName({$ps});
        }
        ''';
    }

    String generateSub(String name, List<ParameterElement> params, List<FieldElement> fes) {
        final fields = params.map((e) => 'final ${e.typeName} _${e.name};').join('\n');
        final cp = params.map((e) => 'this._${e.name}').join(', ');
        final getters = params.map((e) => '@override\n ${e.typeName} get ${e.name} => _${e.name};').join('\n');

        final cps = params.map((e) => 'Object ${e.name} = UNSET').join(', ');
        final sts = params.map((e) => '${e.name} == UNSET ? _${e.name} : ${e.name} as ${e.typeName}').join(',\n');
        final tss = params.map((e) => '${e.name}: \$${e.name}').join(', ');

        final cfs = fes.map((e) => '${e.typeName} _${e.name};').join('\n');
        final caches = fes.map((e) => '''
        @override
        ${e.typeName} get ${e.name.substring(1)} {
            if (_${e.name} == null) {
                _${e.name} = ${e.name};
            }
            return _${e.name};
        }''').join('\n\n');
        return '''
        class _$name extends $name {
            $fields
            $cfs
            _$name($cp): super._();

            $getters

            $caches

            @override
            $name $copyName({$cps}) {
                return _$name($sts);
            }

            @override
            String toString() {
                return '$name($tss)';
            }
        }
        ''';
    }

    String get copyName => '_copy';
}

class StateGenerator extends ValueObjectGenerator<StateAnnotation> {
    @override
    Future<List<ParameterElement>> validate(ClassElement e, BuildStep step) async {
        checkPrivateConstructor(e, 'state');
        e.ensure(e.constructors.length == 2, 'state must have two private constructors: "_", "_create"');
        final cs = e.constructors.where((ee) => ee.name == '_create' && ee.isFactory);
        e.ensure(cs.isNotEmpty, 'states must have a private factory constructor "_create"');
        final c = cs.first;
        final redirect = await getRedirectConstructor(c, step);
        c.ensure('_${e.name}' == redirect.name, 'redirect constuctor return type must be _${e.name} but got ${redirect.name}');
        final params = c.parameters.where((ee) => ee.isRequiredPositional).toList();
        e.ensure(params.length == c.parameters.length, 'state constructor can not have optional or named parameters');
        return params;
    }
}
