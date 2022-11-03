import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:dartlcemodel/dartlcemodel_utils.dart';

/// A [LceModel] which uses cache subscription as a 'source of truth'.
/// When [state] is subscribed it loads cache data refreshing it if cache is stall or whenever cache
/// returns `null`.
/// The model always returns cached data first - then network if data is stall
/// Cache service *must* notify of its data changes!
/// [DATA] Data type of data being held
/// [PARAMS] Params type that identify data being loaded
class CacheThenNetLceModel<DATA extends Object, PARAMS extends Object> implements LceModel<DATA, PARAMS> {
  final ServiceSet<DATA, PARAMS> _serviceSet;
  final Stream<LceState<DATA>>? _startWith;
  final Logger? _logger;

  @override
  final PARAMS params;

  /// Constructor
  /// [params] - Bound params to get entity
  /// [_serviceSet] - Service-set to get data
  /// [_startWith] - Starting sequence for new subscriptions
  /// [_logger] - Logger
  const CacheThenNetLceModel(
      this.params,
      this._serviceSet,
      [
        this._startWith,
        this._logger
      ]
  );

  /// Checks data for if valid.
  /// Runs data update if required
  Stream<LceState<DATA>> _processData(Entity<DATA>? entity) async* {
    _log("Processing data from cache...");
    final data = entity?.data;
    final dataIsValid = true == entity?.isValid();
    if (null != data && dataIsValid) {
      _log("Cache emitted valid data - CONTENT");
      yield LceState.content(data, dataIsValid);
    } else {
      _log("No valid data or data is stall - LOADING");
      yield LceState.loading(data, dataIsValid, null == data ? LoadingType.loading : LoadingType.refreshing);
      try {
        await _getAndSave();
      } on Exception catch(e) {
        _log("Error getting data from network - ERROR: ${e.toString()}", LogLevel.warning);
        yield LceState.error(data, dataIsValid, e);
      } catch (e) {
        _log("Error getting data from network - ERROR: ${e.toString()}", LogLevel.warning);
        yield LceState.error(data, dataIsValid, Exception(e.toString));
      }
    }
  }

  Future<void> _getAndSave() async {
    _log("Getting from network...");
    final fromNetwork = await _serviceSet.net.get(params);
    _log("Saving to cache...");
    await _serviceSet.cache.save(params, fromNetwork);
  }

  @override
  Stream<LceState<DATA>> get state async* {
    _log("Subscribing state...");
    yield* _startWith ?? Stream.empty();
    yield* _serviceSet.cache.getData(params).asyncExpand(_processData);
  }

  @override
  Future<void> refresh() async {
    _log("Refreshing...");
    await _serviceSet.cache.invalidate(params);
  }

  _log(String message, [LogLevel level = LogLevel.debug]) {
    _logger?.log(level, message);
  }
}