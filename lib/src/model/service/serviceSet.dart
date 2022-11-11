import '../../../dartlcemodel_model.dart';

/// Service-set - a set of net and cache services
/// [D] Data type
/// [P] Params that identify data type
abstract class ServiceSet<D extends Object, P extends Object> {
  /// Net service
  abstract final NetService<D, P> net;

  /// Cache service
  abstract final CacheService<D, P> cache;

  /// Creates a service set given [cache] and [net] services
  const factory ServiceSet(CacheService<D, P> cache, NetService<D, P> net) = _ServiceSetImpl;
}

class _ServiceSetImpl<D extends Object, P extends Object> implements ServiceSet<D, P> {
  @override
  final CacheService<D, P> cache;

  @override
  final NetService<D, P> net;

  const _ServiceSetImpl(this.cache, this.net);
}