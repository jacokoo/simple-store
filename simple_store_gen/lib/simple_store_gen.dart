import 'package:build/build.dart';
import 'package:simple_store_gen/src/action.dart';
import 'package:simple_store_gen/src/page.dart';
import 'package:simple_store_gen/src/state.dart';
import 'package:simple_store_gen/src/value.dart';
import 'package:source_gen/source_gen.dart';

Builder actionBuilder(BuilderOptions options) {
    return SharedPartBuilder([ActionGenerator()], 'action');
}

Builder stateBuilder(BuilderOptions options) {
    return SharedPartBuilder([StateGenerator()], 'state');
}

Builder valueBuilder(BuilderOptions options) {
    return SharedPartBuilder([ValueGenerator()], 'value');
}

Builder pageBuilder(BuilderOptions options) {
    return SharedPartBuilder([PageGenerator()], 'page');
}
