import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:dartlcemodel/dartlcemodel_utils.dart';

import './cacheThenNetLceModel.dart';

/// A model interface to load data and transmit it to subscribers along with loading operation state
/// The model is bound with [params] that identify the data
/// [DATA] Data type of data being loaded
/// [PARAMS] Params type that identify data being loaded
abstract class LceModel<DATA extends Object, PARAMS extends Object> implements LceUseCase<DATA> {

  /// Params that identify data being loaded
  PARAMS get params;

  /// Creates a model that takes a cached value and then reloads from network if
  /// nothing cached or cached data is stalled
  /// [params] Params that identify data being loaded
  /// [serviceSet] Data service-set
  /// [startWith] Stream that emits before loading start.
  /// [logger] Logging function
  const factory LceModel.cacheThenNet(
    PARAMS params,
    ServiceSet<DATA, PARAMS> serviceSet,
      {
        Stream<LceState<DATA>>? startWith,
        Logger? logger
      }
  ) = CacheThenNetLceModel;
}