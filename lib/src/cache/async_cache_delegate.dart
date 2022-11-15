import 'package:dartlcemodel/dartlcemodel_cache.dart';

/// Delegate that asynchronously performs caching operations
/// [D] - data type to store
/// [P] - params type
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

  /// Wraps a [sync] delegate and adapts it to async world
  const factory AsyncCacheDelegate(SyncCacheDelegate<D, P> sync) = _SyncDelegateAdapter;
}

/// Adapts sync delegate to use in async service
class _SyncDelegateAdapter<D extends Object, P extends Object> implements AsyncCacheDelegate<D, P> {
  final SyncCacheDelegate<D, P> _delegate;

  const _SyncDelegateAdapter(this._delegate);


  @override
  Future<Entity<D>?> get(P params) async {
    return _delegate.get(params);
  }

  @override
  Future<void> save(P params, Entity<D> entity) async {
    _delegate.save(params, entity);
  }

  @override
  Future<void> invalidate(P params) async {
    _delegate.invalidate(params);
  }

  @override
  Future<void> invalidateAll() async {
    _delegate.invalidateAll();
  }

  @override
  Future<void> delete(P params) async {
    _delegate.delete(params);
  }
}