import 'entity_validator.dart';

// Serialized [Never]
const _serializedNever = "Never!";

/// Entity that is never valid
/// Singleton. Use [instance] to get
class NeverValid extends EntityValidator {
  // Never instance
  static const instance = NeverValid._private();

  /// Validator deserializer
  static const deserializer = _NeverValidDeserializer();

  const NeverValid._private();

  @override
  bool isValid() {
    return false;
  }

  @override
  String serialize() {
    return _serializedNever;
  }

  @override
  String toString() {
    return 'NeverValid';
  }
}

// [Never] deserializer
class _NeverValidDeserializer extends EntityValidatorDeserializer {
  const _NeverValidDeserializer();

  @override
  EntityValidator? deserialize(String serialized) {
    return _serializedNever == serialized ? NeverValid.instance : null;
  }
}
