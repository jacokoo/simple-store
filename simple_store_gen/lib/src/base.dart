import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

extension ElementCheck on Element {
    void ensure(bool condition, String message) {
        if (!condition) {
            throw InvalidGenerationSourceError(message, element: this);
        }
    }
}

extension ParameterType on ParameterElement {
    String get typeName => type.getDisplayString(withNullability: false);
}

extension FieldType on FieldElement {
    String get typeName => type.getDisplayString(withNullability: false);
}

abstract class BaseGenerator<T> extends GeneratorForAnnotation<T> {
    @override
    Future<List<String>> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
        element.ensure(element is ClassElement, 'Simple store annotations can only apply to abstract class.');
        final e = element as ClassElement;
        e.ensure(e.isAbstract, 'Simple store annotations can only apply to abstract class.');
        e.fields.forEach((ee) {
            e.ensure(ee.setter == null, 'Can not have mutable fields $ee');
        });

        return doGenerate(e, buildStep);
    }

    Future<List<String>> doGenerate(ClassElement e, BuildStep step);

    void checkPrivateConstructor(ClassElement e, String name) {
        final pc = e.constructors.where((c) =>
            !c.isDefaultConstructor && c.name == '_' && c.parameters.isEmpty
        );
        e.ensure(pc.length == 1, '$name must have a private constructor "_" with no parameters');
    }
}
