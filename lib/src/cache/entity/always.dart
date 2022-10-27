import 'entityValidator.dart';

// Serialized [Always]
const _serializedAlways = "Always!";

/// Entity that is always valid
/// Singleton. Use [instance] to get
class AlwaysValid extends EntityValidator {
  // Always instance
  static const instance = AlwaysValid._private();

  /// Validator deserializer
  static const deserializer = _AlwaysValidDeserializer();

  const AlwaysValid._private();

  @override
  bool isValid() {
    return true;
  }

  @override
  String serialize() {
    return _serializedAlways;
  }

  @override
  String toString() {
    return 'AlwaysValid';
  }
}

// [Always] deserializer
class _AlwaysValidDeserializer extends EntityValidatorDeserializer {
  const _AlwaysValidDeserializer();

  @override
  EntityValidator? deserialize(String serialized) {
    return _serializedAlways == serialized ? AlwaysValid.instance : null;
  }
}
