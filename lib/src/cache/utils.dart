import '../../dartlcemodel_cache.dart';

/// [SyncCacheDelegate] with string params extensions
extension StringKeyExtension<D extends Object> on SyncCacheDelegate<D, String> {
  /// Creates an adapter delegate that creates [CacheFriend] params using [stringify] function
  /// Receiver - Delegate with [CacheFriend] params e.g. the one that saves data to files and uses params as file names
  SyncCacheDelegate<D, P> stringifyParams<P extends Object>([ String Function(P params)? stringify ]) {
    return _StringAdapter(this, stringify ?? (p) => p.toString());
  }
}

// String delegate adapter
class _StringAdapter<D extends Object, P extends Object> implements SyncCacheDelegate<D, P> {
  final SyncCacheDelegate<D, String> _delegate;
  final String Function(P params) _stringify;

  /// Constructor
  /// [delegate] Parent delegate
  /// [params] Passed params
  /// [stringify] Params stringifying function
  const _StringAdapter(this._delegate, this._stringify);

  @override
  Entity<D>? get(P params) {
    return _delegate.get(_stringify(params));
  }

  @override
  void save(P params, Entity<D> entity) {
    _delegate.save(_stringify(params), entity);
  }

  @override
  void invalidate(P params) {
    _delegate.invalidate(_stringify(params));
  }

  @override
  void invalidateAll() {
    _delegate.invalidateAll();
  }

  @override
  void delete(P params) {
    _delegate.delete(_stringify(params));
  }
}
