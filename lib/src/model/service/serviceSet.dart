import '../../../dartlcemodel_model.dart';

/// Service-set - a set of net and cache services
/// [D] Data type
/// [P] Params that identify data type
abstract class ServiceSet<D extends Object, P extends Object> {
  /// Net service
  abstract NetService<D, P> net;

  /// Cache service
  abstract CacheService<D, P> cache;
}