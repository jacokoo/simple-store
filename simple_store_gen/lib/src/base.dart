import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

Future<AstNode> getAst(Element c, BuildStep step) async {
    try {
        return c.session.getParsedLibraryByElement(c.library).getElementDeclaration(c).node;
    } on InconsistentAnalysisException {
        final id = await step.resolver.assetIdForElement(c);
        final lib = await step.resolver.libraryFor(id);
        return lib.session.getParsedLibraryByElement(lib).getElementDeclaration(c).node;
    }
}

class TypedItem {
    final String type;
    final String name;
    TypedItem(this.type, this.name);

    static Future<TypedItem> fromParam(ParameterElement item, BuildStep step) {
        return _create(item, item.type, step);
    }

    static Future<TypedItem> fromField(FieldElement item, BuildStep step) {
        return _create(item, item.type, step);
    }

    static Future<TypedItem> _create(Element e, DartType type, BuildStep step) async {
        var name = type.getDisplayString(withNullability: false);
        if (
            type.isDartAsyncFuture || type.isDartAsyncFutureOr ||
            type.isDartCoreBool || type.isDartCoreDouble ||
            type.isDartCoreFunction || type.isDartCoreInt ||
            type.isDartCoreIterable || type.isDartCoreList ||
            type.isDartCoreMap || type.isDartCoreNull ||
            type.isDartCoreNum || type.isDartCoreObject ||
            type.isDartCoreSet || type.isDartCoreString ||
            type.isDartCoreSymbol
        ) return TypedItem(name, e.name);
        try {
            final ast = await getAst(e, step);
            if (ast.beginToken.next.toString() == '.') {
                name = '${ast.beginToken.toString()}.$name';
            }
        } catch (ex) {
            print('get ast for $e failed');
        }
        return TypedItem(name, e.name);
    }
}

extension ElementCheck on Element {
    void ensure(bool condition, String message) {
        if (!condition) {
            throw InvalidGenerationSourceError(message, element: this);
        }
    }
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
