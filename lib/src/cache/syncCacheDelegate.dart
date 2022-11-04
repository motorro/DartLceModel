import '../../dartlcemodel_cache.dart';

/// Delegate that synchronously performs caching operations
abstract class SyncCacheDelegate<D extends Object, P extends Object> {
  /// Returns data if cached
  /// [params] Caching key
  Entity<D>? get(P params);

  /// Saves data to cache
  /// [params] Caching key
  /// [entity] Entity to cache
  void save(P params, Entity<D> entity);

  /// Invalidates cached value
  /// [params] Caching key
  void invalidate(P params);

  /// Invalidates all cached values
  void invalidateAll();

  /// Deletes cached value
  /// [params] Caching key
  void delete(P params);
}