/// Define actions that the store handle.
/// A Store only can handle a single SimpleAction type.
/// Actions could be created anywhare, but it can only be handled use private
/// method `_when`, so define it within the file which defines the store.
abstract class SimpleAction {
    const SimpleAction();
}

/// State hold immutable data.
/// A Store can hold any number of states.
/// States are created by private factory constructor `_create`,
/// and change by private method `_copy`,
/// so define it within the file which defines the store.
abstract class SimpleState {}

/// Define pages for Module
abstract class SimplePage {
    const SimplePage();

    // use a long name to avoid field name conflict
    String get generatedPageName;
}

/// This is an interal object used in _copy.
const UNSET = Object();
