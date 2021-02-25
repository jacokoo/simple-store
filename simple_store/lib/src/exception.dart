import 'package:simple_store_base/simple_store_base.dart';

class UnknownActionException implements Exception {
    final SimpleAction action;
    UnknownActionException(this.action);

    @override
    String toString() {
        return 'Unknown action: $action';
    }
}

class UnknownStateException implements Exception {
    final Object type;
    final Type store;
    UnknownStateException(this.type, this.store);

    @override
    String toString() {
        return 'State $type is not found in $store. Note that state must initialized before get/set';
    }
}

class UnknownEventException implements Exception {
    final Type type;
    UnknownEventException(this.type);

    @override
    String toString() {
        return 'Event Emitter $type is not found. Note that event must initialized before listen';
    }
}

class InitializerEndedException implements Exception {
    final Object initializer;
    InitializerEndedException(this.initializer);

    @override
    String toString() {
        return '$initializer is out of scope';
    }
}
