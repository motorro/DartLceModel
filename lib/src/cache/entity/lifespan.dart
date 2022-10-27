import '../../../dartlcemodel_utils.dart';
import 'entityValidator.dart';

/// Uses creation time and TTL to validate
class Lifespan extends EntityValidator {
  final int _wasBorn;
  final int _ttl;
  final _LifeSpanValidation _validation;

  /// Validator deserializer
  static EntityValidatorDeserializer deserializer([Clock clock = Clock.system]) {
    return _LifespanDeserializer(clock);
  }

  /// Uses creation time and TTL to validate
  /// [wasBorn] Time entity was born
  /// [ttl] Time to live
  /// [validation] Validation delegate to create a dynamic or snapshot validator
  const Lifespan._private(this._wasBorn, this._ttl, this._validation);

  /// Creates dynamic validator that will change it's [EntityValidator.isValid] in time
  /// [ttl] Time to live
  /// [clock] Clock implementation
  factory Lifespan.dynamic(int ttl, [ Clock clock = Clock.system ]) {
    final wasBorn = clock.getMillis();
    return Lifespan._private(
        wasBorn,
        ttl,
        _DynamicValidation(clock)
    );
  }

  /// Creates a snapshot that may be serialized and deserialized back to dynamic [Lifespan]
  /// [ttl] Time to live
  /// [clock] Clock implementation
  factory Lifespan.snapshot(int ttl, [ Clock clock = Clock.system ]) {
    final wasBorn = clock.getMillis();
    return Lifespan._private(
        wasBorn,
        ttl,
        _SnapshotValidation(_isValid(wasBorn, ttl, clock))
    );
  }

  @override
  bool isValid() {
    return _validation.isValid(_wasBorn, _ttl);
  }

  @override
  String serialize() {
    return 'Lifespan: $_wasBorn/$_ttl';
  }

  @override
  EntityValidator createSnapshot() {
    return Lifespan._private(_wasBorn, _ttl, _SnapshotValidation(isValid()));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityValidator &&
          isValid() == other.isValid();

  @override
  int get hashCode => isValid().hashCode;

  @override
  String toString() {
    return 'Valid till: ${_wasBorn + _ttl}))}';
  }
}

/// A delegate that performs validation
/// Used to alter Lifespan dynamic instance or a snapshot
abstract class _LifeSpanValidation {
  /// Checks if [Lifespan] is valid
  bool isValid(int wasBorn, int ttl);
}

/// Use in dynamic [Lifespan] with current time check
class _DynamicValidation implements _LifeSpanValidation {
  final Clock _clock;

  /// Creates [_DynamicValidation] which checks validity against current [clock] time
  const _DynamicValidation(Clock clock) : _clock = clock;

  @override
  bool isValid(int wasBorn, int ttl) {
    return _isValid(wasBorn, ttl, _clock);
  }
}

/// Use in snapshot [Lifespan] to fix the validity at the time of creation
class _SnapshotValidation implements _LifeSpanValidation {
  final bool _valid;

  /// Creates a fixed validation which state is always [valid]
  const _SnapshotValidation(bool valid) : _valid = valid;

  @override
  bool isValid(int wasBorn, int ttl) {
    return _valid;
  }
}

/// Checks if entity has expired
bool _isValid(int wasBorn, int ttl, Clock clock) {
  return clock.getMillis() - wasBorn <= ttl;
}

// [Lifespan] deserializer
class _LifespanDeserializer extends EntityValidatorDeserializer {
  /// Pattern to deserialize
  static final _deserializationPattern = RegExp(r'^Lifespan:\s(\d+)/(\d+)$');

  static Lifespan? _withTemporal(String serialized, Lifespan Function(int wasBorn, int ttl) action) {
    final match = _deserializationPattern.firstMatch(serialized);
    if (null == match) {
      return null;
    }
    final wasBorn = match.group(1);
    final ttl = match.group(2);
    if (null == wasBorn || null == ttl) {
      return null;
    }
    return action(int.parse(wasBorn), int.parse(ttl));
  }

  final Clock _clock;

  const _LifespanDeserializer([this._clock = Clock.system]);

  @override
  EntityValidator? deserialize(String serialized) {
    return _withTemporal(
        serialized,
        (wasBorn, ttl) => Lifespan._private(wasBorn, ttl, _DynamicValidation(_clock))
    );
  }

  @override
  EntityValidator? deserializeSnapshot(String serialized) {
    return _withTemporal(
        serialized,
        (wasBorn, ttl) => Lifespan._private(wasBorn, ttl, _SnapshotValidation(_isValid(wasBorn, ttl, _clock)))
    );
  }
}
