import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:simple_store_gen/src/base.dart';
import 'package:simple_store_base/simple_store_base.dart';

class Redirect {
    final String name;
    final List<String> generics;
    Redirect(this.name, this.generics);
}

class ConstructorInfo {
    final String name;
    final List<ParameterElement> params;
    final Redirect redirect;
    ConstructorInfo(this.name, this.params, this.redirect);
}

class ActionGenerator extends BaseGenerator<ActionAnnotation> {
    @override
    Future<List<String>> doGenerate(ClassElement e, BuildStep step) async {
        checkPrivateConstructor(e, 'action');
        e.ensure(e.methods.isEmpty, 'action can not have methods');

        final css = e.constructors.where((c) => c.name != '_').map((c) async {
            c.ensure(!c.isDefaultConstructor, 'actions can not have default constructor');
            c.ensure(c.isConst, 'action constructor must be const');
            final re = await getRedirectConstructor(c, step);
            c.ensure(re.generics.length < 2, 'action constructor can at most have one generic type');
            if (re.generics.isEmpty) {
                re.generics.add('void');
            }
            return ConstructorInfo(c.name, c.parameters, re);
        });
        final cs = await Future.wait(css);

        final fns = cs.map((e) => '@required Future<${e.redirect.generics.first}> Function(${e.redirect.name}) ${e.name}').join(', ');
        final sts = cs.map((e) => 'if (this is ${e.redirect.name}) return ${e.name}(this);').join('\n');
        return ['''
        mixin _\$${e.name} {
            Future<dynamic> _when({$fns}) {
                $sts
                return null;
            }
        }
        '''] + cs.map((ee) => createConstructorClass(ee, e.name, true, false)).toList();
    }

}

String createConstructorClass(ConstructorInfo info, String parent, bool haveGeneric, bool haveName) {
    final fields = info.params.map((e) => 'final ${e.typeName} ${e.name};');
    final named = info.params.where((e) => e.isNamed).map((e) => 'this.${e.name}').join(',');
    final df = info.params.where((e) => e.isRequiredPositional).map((e) => 'this.${e.name}').join(',');
    final ops = info.params.where((e) => e.isOptionalPositional).map((e) => 'this.${e.name}').join(',');
    final args = <String>[];
    if (df.isNotEmpty) args.add(df);
    if (named.isNotEmpty) args.add('{$named}');
    if (ops.isNotEmpty) args.add('[$ops]');

    final t = haveGeneric ? (info.redirect.generics.first == 'void' ? '' : '<T>') : '';
    final tss = info.params.map((e) => '${e.name}: \$${e.name}').join(', ');
    final name = haveName ? '\n@override\nString get name => \'${info.name}\';\n' : '';
    return '''
    class ${info.redirect.name}$t extends $parent {
        ${fields.join('\n')}
        const ${info.redirect.name}(${args.join(',')}): super._();
        $name
        @override
        String toString() {
            return '${parent}.${info.name}($tss)';
        }
    }
    ''';
}

Future<Redirect> getRedirectConstructor(ConstructorElement c, BuildStep step) async {
    if (c.redirectedConstructor != null) {
        final type = c.redirectedConstructor.returnType;
        return Redirect(
            type.element.name,
            type.typeArguments.map((e) => e.element.name).toList()
        );
    }
    final ast = await _getAst(c, step);
    c.ensure(ast.endToken.stringValue == ';', 'expect ";"');
    var t = ast.endToken.previous;
    final gs = <String>[];
    if (t.stringValue == '>') {
        t = t.previous;
        c.ensure(t.stringValue != '<', 'expect generic type');
        while (t.stringValue != '<' && t.charOffset > c.nameOffset) {
            final v = t.value();
            if (v == ',') {
                t = t.previous;
                continue;
            };
            gs.insert(0, v.toString());
            t = t.previous;
        }
        c.ensure(t.stringValue == '<', 'expect "<" but got ${t.stringValue}');
        t = t.previous;
    }

    final name = t.value().toString();
    t = t.previous;
    c.ensure(name.startsWith('_'), 'expect private class name');
    c.ensure(t.stringValue == '=', 'expect "="');
    return Redirect(name, gs);
}

Future<AstNode> _getAst(ConstructorElement c, BuildStep step) async {
    try {
        return c.session.getParsedLibraryByElement(c.library).getElementDeclaration(c).node;
    } on InconsistentAnalysisException {
        final id = await step.resolver.assetIdForElement(c);
        final lib = await step.resolver.libraryFor(id);
        return lib.session.getParsedLibraryByElement(lib).getElementDeclaration(c).node;
    }
}
