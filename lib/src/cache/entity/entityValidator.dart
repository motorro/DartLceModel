import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/src/cache/entity/simple.dart';

/// Entity validator
/// Controls entity lifetime
abstract class EntityValidator {

  const EntityValidator();

  /// If true cached entity is valid.
  bool isValid();

  /// A way to serialize entity
  String serialize();

  /// Crates a snapshot of validator preserving it's current
  /// [EntityValidator.isValid] value
  EntityValidator createSnapshot() {
    return Simple(isValid());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EntityValidator &&
              isValid() == other.isValid();

  @override
  int get hashCode => isValid().hashCode;
}

/// Delegates [EntityValidator] to [_validator] provided by host class
mixin EntityValidatorMixin implements EntityValidator {

  EntityValidator get validator;

  @override
  EntityValidator createSnapshot() {
    return validator.createSnapshot();
  }

  @override
  bool isValid() {
    return validator.isValid();
  }

  @override
  String serialize() {
    return validator.serialize();
  }
}

/// Deserializes validator from string
abstract class EntityValidatorDeserializer {

  const EntityValidatorDeserializer();

  /// Deserializes validator from string if string is recognized
  /// [serialized] - Serialized validator
  /// [Deserialized] - validator or null if not recognized
  EntityValidator? deserialize(String serialized);

  /// Deserializes an immutable snapshot of validator that does not change [EntityValidator.isValid] with time
  /// [serialized] Serialized validator
  /// [Deserialized] validator or null if not recognized
  EntityValidator? deserializeSnapshot(String serialized) {
    return deserialize(serialized)?.createSnapshot();
  }
}
