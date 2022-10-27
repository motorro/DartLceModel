import 'entityValidator.dart';

/// A simple validator which state is defined on creation
/// May be used to fix the [isValid] state of dynamic validator such as [Lifespan]
class Simple extends EntityValidator {

  /// Validator deserializer
  static const deserializer = _SimpleDeserializer();

  final bool _valid;
  @override
  bool isValid() {
    return _valid;
  }

  /// A simple validator which state is defined on creation
  /// May be used to fix the [isValid] state of dynamic validator such as [Lifespan]
  /// [valid] Validity state
  const Simple(this._valid);

  @override
  String serialize() {
    return 'Simple: ${isValid()}';
  }
}

// [Simple] deserializer
class _SimpleDeserializer extends EntityValidatorDeserializer {
  /// Pattern to deserialize
  static final _deserializationPattern = RegExp(r'^Simple:\s(true|false)$');

  const _SimpleDeserializer();

  @override
  EntityValidator? deserialize(String serialized) {
    final match = _deserializationPattern.firstMatch(serialized);
    if (null == match) {
      return null;
    }
    return Simple('true' == match.group(1)?.toLowerCase());
  }
}
