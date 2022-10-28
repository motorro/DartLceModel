/// Generates a cache-friendly key value for parameters
abstract class CacheFriend {
  /// A cache key
  String get cacheKey;

  /// Creates a simple [CacheFriend] with [key]
  const factory CacheFriend.create(String key) = _CacheFriendImpl;
}

/// [CacheFriend] implementation
class _CacheFriendImpl implements CacheFriend {
  final String _cacheKey;

  const _CacheFriendImpl(this._cacheKey);

  @override
  String get cacheKey => _cacheKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CacheFriendImpl &&
          runtimeType == other.runtimeType &&
          _cacheKey == other._cacheKey;

  @override
  int get hashCode => _cacheKey.hashCode;

  @override
  String toString() {
    return 'CacheFriendImpl{cacheKey: $_cacheKey}';
  }
}