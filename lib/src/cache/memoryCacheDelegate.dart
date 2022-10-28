import 'package:dartlcemodel/dartlcemodel_cache.dart';

/// A simple memory cache for cache-service
/// [D] Data type
/// [P] Params type
class MemoryCacheDelegate<D extends Object, P extends Object> implements CacheDelegate<D, P> {
  final MemoryDelegateCache<Entity<D>, P> _cache;

  const MemoryCacheDelegate._private(this._cache);

  /// Creates a delegate with backing memory map as a storage
  MemoryCacheDelegate.map() : this._private(_MapCache<Entity<D>, P>());

  @override
  Entity<D>? get(P params) {
    return _cache[params]?.createSnapshot();
  }

  @override
  void save(P params, Entity<D> entity) {
    _cache[params] = entity;
  }

  @override
  void invalidate(P params) {
    final cached = _cache[params];
    if (null != cached) {
      save(params, cached.invalidate());
    }
  }

  @override
  void invalidateAll() {
    _cache.updateAll((_, value) => value.invalidate());
  }

  @override
  void delete(P params) {
    _cache.delete(params);
  }
}

/// Memory cache abstraction to handle cache size, LRU, etc (later)
abstract class MemoryDelegateCache<D extends Object, P extends Object> {
  /// Gets the value for [key] or null
  D? operator [](P key);

  /// Sets the [value] for [key] or null
  void operator []=(P key, D value);

  /// Updates all values
  void updateAll(D Function(P key, D value) update);

  /// Deletes the value for [key]
  void delete(P key);
}

/// Simple [MemoryDelegateCache] using [Map]
class _MapCache<D extends Object, P extends Object> implements MemoryDelegateCache<D, P> {
  final Map<P, D> _cache = {};

  _MapCache();

  @override
  D? operator [](P key) {
    return _cache[key];
  }

  @override
  void operator []=(P key, D value) {
    _cache[key] = value;
  }

  @override
  void updateAll(D Function(P key, D value) update) {
    _cache.updateAll(update);
  }

  @override
  void delete(P key) {
    _cache.remove(key);
  }
}