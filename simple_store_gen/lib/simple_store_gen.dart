import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/action.dart';
import 'src/page.dart';
import 'src/state.dart';
import 'src/value.dart';

/// Builder for build actions
Builder actionBuilder(BuilderOptions options) {
    return SharedPartBuilder([ActionGenerator()], 'action');
}

/// Builder for build state object
Builder stateBuilder(BuilderOptions options) {
    return SharedPartBuilder([StateGenerator()], 'state');
}

/// Builder for build value object
Builder valueBuilder(BuilderOptions options) {
    return SharedPartBuilder([ValueGenerator()], 'value');
}

/// Builder for build pages
Builder pageBuilder(BuilderOptions options) {
    return SharedPartBuilder([PageGenerator()], 'page');
}
