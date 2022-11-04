import '../../dartlcemodel_cache.dart';

/// Delegate that asynchronously performs caching operations
abstract class AsyncCacheDelegate<D extends Object, P extends Object> {
  /// Returns data if cached
  /// [params] Caching key
  Future<Entity<D>?> get(P params);

  /// Saves data to cache
  /// [params] Caching key
  /// [entity] Entity to cache
  Future<void> save(P params, Entity<D> entity);

  /// Invalidates cached value
  /// [params] Caching key
  Future<void> invalidate(P params);

  /// Invalidates all cached values
  Future<void> invalidateAll();

  /// Deletes cached value
  /// [params] Caching key
  Future<void> delete(P params);
}