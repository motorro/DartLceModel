import 'package:dartlcemodel/dartlcemodel_cache.dart';

/// Cache-controlling entity.
/// Implement this interface for cache control
abstract class Entity<T extends Object> implements EntityValidator {
  /// Entity data
  abstract final T data;

  /// Creates an entity with [data] validated by [validator]
  const factory Entity.create(T data, EntityValidator validator) = EntityImpl<T>;

  /// Transforms Entity [data] to another entity data with [mapper]
  /// Validation remains the same
  Entity<R> map<R extends Object>(R Function(T) mapper);

  /// Crates a snapshot of validator preserving it's current [EntityValidator.isValid] value
  @override
  Entity<T> createSnapshot();

  /// Creates an invalid entity out of this one
  Entity<T> invalidate();
}

/// [Entity] implementation
class EntityImpl<T extends Object> with EntityValidatorMixin implements Entity<T> {

  /// Data
  @override
  final T data;

  /// Data validator
  @override
  final EntityValidator validator;

  /// Constructor
  /// Create an entity with [data] validated by [validator]
  const EntityImpl(this.data, this.validator);

  /// Copy constructor
  EntityImpl<T> copyWith({ T? data, EntityValidator? validator }) {
    return EntityImpl(
        data ?? this.data,
        validator ?? this.validator
    );
  }

  @override
  Entity<R> map<R extends Object>(R Function(T) mapper) {
    return EntityImpl(mapper(data), validator);
  }

  @override
  Entity<T> createSnapshot() {
    return copyWith(validator: validator.createSnapshot());
  }

  @override
  Entity<T> invalidate() {
    return copyWith(validator: NeverValid.instance);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityImpl &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          validator == other.validator;

  @override
  int get hashCode => data.hashCode ^ validator.hashCode;

  @override
  String toString() {
    return 'EntityImpl{data: $data, validator: $validator}';
  }
}

