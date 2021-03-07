import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:simple_store_base/simple_store_base.dart';
import 'package:simple_store_gen/src/base.dart';
import 'package:simple_store_gen/src/action.dart';

class PageGenerator extends BaseGenerator<PageAnnotation> {
    @override
    Future<List<String>> doGenerate(ClassElement e, BuildStep step) async {
        checkPrivateConstructor(e, 'page');
        e.ensure(e.methods.isEmpty, 'page can not have methods');

        final css = e.constructors.where((c) => c.name != '_').map((c) async {
            c.ensure(!c.isDefaultConstructor, 'pages can not have default constructor');
            c.ensure(c.isConst, 'page constructor must be const');
            final re = await getRedirectConstructor(c, step);
            c.ensure(re.generics.isEmpty, 'page constructor can not have generic types');
            return ConstructorInfo(c.name, c.parameters, re);
        });
        final cs = await Future.wait(css);

        final fns = cs.map((e) => '@required Widget Function(${e.redirect.name}) ${noDash(e.name)}').join(', ');
        final sts = cs.map((e) => 'if (this is ${e.redirect.name}) return ${noDash(e.name)}(this);').join('\n');
        final ccs = await Future.wait(cs.map((ee) => createConstructorClass(ee, e.name, false, true, step)));

        return ['''
        mixin _\$${e.name} {
            Widget _when({$fns}) {
                $sts
                assert(false, 'Unknown page instance: $this');
                return null;
            }

            ${generateIsType(cs)}
        }
        '''] + ccs;
    }
}
