import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_utils.dart';

/// Cache-control [EntityValidator] factory for operations
abstract class EntityValidatorFactory {
  /// Creates [Lifespan] factory
  /// [cacheTtl] Cache TTL
  /// [clock] System clock
  factory EntityValidatorFactory.lifespan(int cacheTtl, [ Clock clock = Clock.system ]) {
    return _LifespanValidatorFactory(cacheTtl, clock);
  }

  /// Creates entity cache-control
  /// [serialized] - serialized validator string. Creates a new validator if null is passed
  /// Throws Exception if serialized can't be deserialized
  EntityValidator create([ String? serialized ]);

  /// Creates a snapshot of entity cache-control.The [EntityValidator.isValid] evaluated at the time of creation.
  /// [serialized] - serialized validator string. Creates a valid snapshot if null is passed
  /// Throws Exception if serialized can't be deserialized
  EntityValidator createSnapshot([ String? serialized ]);
}

/// Creates [Lifespan] as a cache-control
class _LifespanValidatorFactory implements EntityValidatorFactory {
  final int _cacheTtl;
  final Clock _clock;
  final EntityValidatorDeserializer _deserializer;

  /// Constructor
  /// [_cacheTtl] Cache TTL
  /// [_clock] System clock
  _LifespanValidatorFactory(this._cacheTtl, [ this._clock = Clock.system ]) : _deserializer = Lifespan.deserializer(_clock);

  @override
  EntityValidator create([String? serialized]) {
    final deserialized = (null != serialized) ? _deserializer.deserialize(serialized) : null;
    return deserialized ?? Lifespan.dynamic(_cacheTtl, _clock);
  }

  @override
  EntityValidator createSnapshot([String? serialized]) {
    final deserialized = (null != serialized) ? _deserializer.deserializeSnapshot(serialized) : null;
    return deserialized ?? Lifespan.snapshot(_cacheTtl, _clock);
  }
}