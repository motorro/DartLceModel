import '../../dartlcemodel_cache.dart';

/// Data combined with full cached key to validate we get exactly what we are looking for
/// For example, DiskLruCache has strict requirements and limited length of a cache key and
/// hashing of keys may be required to fit into requirements - thus there is a possibility of key
/// clash.
class DataWithCacheKey<D extends Object> {
  final D data;
  final String cacheKey;

  /// Constructor
  /// [data] Original data
  /// [cacheKey] Full unmodified cache key
  const DataWithCacheKey(this.data, this.cacheKey);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataWithCacheKey &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          cacheKey == other.cacheKey;

  @override
  int get hashCode => data.hashCode ^ cacheKey.hashCode;

  @override
  String toString() {
    return 'DataWithCacheKey{data: $data, cacheKey: $cacheKey}';
  }
}

/// Wraps [delegate] adding unmodified [CacheFriend.cacheKey] to the mix with data.
/// Validates that key on [get] and returns null if it is not equals original.
/// Helps to make sure the data returned is not a result of clashed cache key.
class CacheFriendDelegate<D extends Object, P extends CacheFriend> implements CacheDelegate<D, P> {
  final CacheDelegate<DataWithCacheKey<D>, P> _delegate;

  /// Constructor
  /// [delegate] Cache delegate
  const CacheFriendDelegate(CacheDelegate<DataWithCacheKey<D>, P> delegate) : _delegate = delegate;

  @override
  Entity<D>? get(P params) {
    final fromCache = _delegate.get(params);
    if (null == fromCache || params.cacheKey != fromCache.data.cacheKey) {
      return null;
    } else {
      return fromCache.map((it) => it.data);
    }
  }

  @override
  void save(P params, Entity<D> entity) {
    _delegate.save(
        params,
        entity.map((it) => DataWithCacheKey(it, params.cacheKey))
    );
  }

  @override
  void invalidate(P params) {
    _delegate.invalidate(params);
  }

  @override
  void invalidateAll() {
    _delegate.invalidateAll();
  }

  @override
  void delete(P params) {
    _delegate.delete(params);
  }
}

/// [CacheFriend] extensions
extension CacheFriendExtension<D extends Object> on CacheDelegate<D, CacheFriend> {
  /// Creates an adapter delegate that creates [CacheFriend] params using [stringify] function
  /// Receiver - Delegate with [CacheFriend] params e.g. the one that saves data to files and uses params as file names
  CacheDelegate<D, P> makeFriendParams<P extends Object>(String Function(P params) stringify) {
    return _FriendAdapter(this, stringify);
  }
}

// Cache-friend delegate adapter
class _FriendAdapter<D extends Object, P extends Object> implements CacheDelegate<D, P> {
  final CacheDelegate<D, CacheFriend> _delegate;
  final String Function(P params) _stringify;

  CacheFriend _createFriend(P params) {
    return _FriendStringifier(params, _stringify);
  }

  /// Constructor
  /// [delegate] Parent delegate
  /// [params] Passed params
  /// [stringify] Params stringifying function
  const _FriendAdapter(this._delegate, this._stringify);

  @override
  Entity<D>? get(P params) {
    return _delegate.get(_createFriend(params));
  }

  @override
  void save(P params, Entity<D> entity) {
    _delegate.save(_createFriend(params), entity);
  }

  @override
  void invalidate(P params) {
    _delegate.invalidate(_createFriend(params));
  }

  @override
  void invalidateAll() {
    _delegate.invalidateAll();
  }

  @override
  void delete(P params) {
    _delegate.delete(_createFriend(params));
  }
}

/// Cache-friend params stringifier
class _FriendStringifier<P extends Object> implements CacheFriend {
  final String _cacheKey;

  /// Constructor
  /// [params] Source params
  /// [stringify] Stringify function
  _FriendStringifier(P params, String Function(P params) stringify) : _cacheKey = stringify(params);

  @override
  String get cacheKey => _cacheKey;
}