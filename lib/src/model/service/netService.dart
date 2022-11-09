
import 'package:dartlcemodel/dartlcemodel_cache.dart';

/// Interface to load an [Entity] from network
/// [D] Data type
/// [P] Params that identify data type
abstract class NetService<D extends Object, P extends Object> {

  /// Gets entity from network or throws on error
  /// [params] Params that distinguish entity
  Future<Entity<D>> get(P params);
}