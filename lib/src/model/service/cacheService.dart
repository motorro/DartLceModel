import 'dart:async';

import 'package:dartlcemodel/dartlcemodel_cache.dart';

import './asyncDelegateCacheService.dart';

/// Interface to cache an [Entity] locally
/// Cache should notify subscribers that data has been updated through [getData] channel
/// [D] Data type
/// [P] Params that identify data type
abstract class CacheService<D extends Object, P extends Object> {

  /// Creates a [SyncCacheDelegate] cache service
  /// [delegate] Delegate that synchronously performs caching actions
  factory CacheService.withSyncDelegate(SyncCacheDelegate<D, P> delegate) {
    return AsyncDelegateCacheService(AsyncCacheDelegate(delegate));
  }

  /// Creates a [AsyncCacheDelegate] cache service
  /// [delegate] Delegate that synchronously performs caching actions
  factory CacheService.withAsyncDelegate(AsyncCacheDelegate<D, P> delegate) = AsyncDelegateCacheService;

  /// Subscribes to cache data updates.
  /// Cache update listeners with new cached values.
  /// [params] Params to notify of changes
  Stream<Entity<D>?> getData(P params);

  /// Saves entity in a cache
  /// [params] Params that identify entity
  /// [entity] Data to save
  Future<void> save(P params, Entity<D> entity);

  /// Makes cache service to refetch cached data updating subscribers with [params]
  /// [params] Params that identify entity
  Future<void> refetch(P params);

  /// Makes cache service to refetch cached data for all active subscribers
  Future<void> refetchAll();

  /// Invalidates cached value
  /// [params] Params that identify entity
  Future<void> invalidate(P params);

  /// Invalidates all cached values
  Future<void> invalidateAll();

  /// Deletes cached value.
  /// The [getData] observable for the same key will emit `null`.
  /// [params] Caching key
  Future<void> delete(P params);
}