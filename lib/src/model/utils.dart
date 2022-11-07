import 'dart:async';

import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';

/// [LceState] stream extensions
extension LceStreamExtension<DATA extends Object> on Stream<LceState<DATA>> {
  /// Emits error event when state is [LceError] and [predicate] returns true
  Stream<LceState<DATA>> errorIf(bool Function(LceError<DATA> error) predicate) => map((state) {
    if (state is LceError<DATA> && predicate(state)) {
      throw state.error;
    } else {
      return state;
    }
  });

  /// Emits error on every [LceError]
  Stream<LceState<DATA>> errorOnError() => errorIf((_) => true);

  /// Emits error on every [LceError] with empty data
  Stream<LceState<DATA>> errorOnEmptyError() => errorIf((error) => null == error.data);

  /// Returns model's data stream dropping state information
  /// [DATA] Source model data type
  /// [errorPredicate] A predicate to check error state. If predicate returns true, the stream
  /// emits error event
  Stream<DATA> getData([bool Function(LceError<DATA> error)? errorPredicate]) => errorIf(errorPredicate ?? (_) => true)
      .where((state) => null != state.data)
      .map((state) => state.data!)
      .distinct();

  /// Model's _valid_ data stream with state information dropped.
  /// [DATA] Source model data type
  /// [errorPredicate] A predicate to check error state. If predicate returns true, the stream
  /// emits error event
  Stream<DATA> validData([bool Function(LceError<DATA> error)? errorPredicate]) => errorIf(errorPredicate ?? (_) => true)
      .where((state) => null != state.data && state.dataIsValid)
      .map((state) => state.data!)
      .distinct();

  /// Model's data stream with state information dropped.
  /// No error events
  /// [DATA] Source model data type
  Stream<DATA> dataNoErrors() => getData((_) => false);

  /// Model's data stream with state information dropped.
  /// Emits error event on upstream error state
  /// [DATA] Source model data type
  Stream<DATA> dataWithErrors() => getData((_) => true);

  /// Model's data stream with state information dropped.
  /// Emits error event on upstream error state when upstream has no data
  /// [DATA] Source model data type
  Stream<DATA> dataWithEmptyErrors() => getData((state) => null == state.data);

  /// Maps each [DATA] to future for [DATA_2] and merges back to LceState.
  /// If error occurs in [mapper] emits [LceError].
  /// Example: load some [DATA_2] from server using original [DATA] as a parameter.
  /// [DATA_2] Resulting data type
  /// mapper Data mapper
  Stream<LceState<DATA_2>> flatMapSingleData<DATA_2 extends Object>(Future<DATA_2> Function(DATA data) mapper) =>
      asyncMap((state) async {
        final data1 = state.data;
        if (null == data1) {
          return LceState<DATA_2>.loading(null, false);
        } else {
          try {
            return state.combine(LceState.content(await mapper(data1), true), (_, data2) => data2);
          } on Exception catch (e) {
            return LceState.error(null, false, e);
          } catch (e) {
            return LceState.error(null, false, Exception(e.toString()));
          }
        }
      });

  /// Substitutes [LceLoading] with empty data with state produced by [block]
  /// [block] transformation block
  Stream<LceState<DATA>> onEmptyLoadingReturn(LceState<DATA> Function(LceLoading<DATA> loading) block) => map((state) =>
    state.whenElse(
        loading: (loading) => null == loading.data ? block(loading) : loading,
        onElse: (state) => state
    )
  );

  /// Substitutes [LceLoading] empty data with data produced by [block]
  /// [block] Item creation block
  Stream<LceState<DATA>> onEmptyLoadingReturnData(DATA Function() block) => map((state) =>
    state.whenElse(
        loading: (loading) => null == loading.data ? LceState.loading(block(), loading.dataIsValid, loading.type) : loading,
        onElse: (state) => state
    )
  );

  /// Maps an upstream error to LceError
  /// [errorData] Evaluates data for error state
  Stream<LceState<DATA>> errorToLce([DATA? Function(Object error)? errorData]) => transform(
    StreamTransformer.fromHandlers(
      handleError: (error, stacktrace, sink) {
        sink.add(
            LceState.error(
              null != errorData ? errorData(error) : null,
              false,
              error is Exception ? error : Exception(error.toString())
            )
        );
      }
    )
  );
}

/// [LceState] stream extensions
extension LceUseCaseExtension<DATA extends Object> on LceUseCase<DATA> {
  /// Creates a use-case wrapper that converts [DATA_1] to [DATA_2]
  /// [DATA_2] Resulting data type
  /// [mapper] Data mapper
  LceUseCase<DATA_2> map<DATA_2 extends Object>(DATA_2 Function(DATA data) mapper) => _LceUseCaseMapper<DATA, DATA_2>(this, mapper);

  /// Takes the [LceUseCase.state] of model that is being refreshed each time [refreshStream] emits a value
  /// Useful when you create a model as a result of mapping of some input (params for example) and the
  /// [LceUseCase.refresh] property becomes invisible for the outside world
  /// [DATA] Source model data type
  /// [refreshStream] Whenever this stream emits a value, the model is refreshed
  Stream<LceState<DATA>> withRefresh(Stream<dynamic> refresh) {
    final controller = StreamController<LceState<DATA>>(sync: true);
    late StreamSubscription<LceState<DATA>> stateSubscription;
    late StreamSubscription<dynamic> refreshSubscription;

    controller.onListen = () {
      stateSubscription = state.listen(controller.add, onError: controller.addError, onDone: controller.close);
      refreshSubscription = refresh.asyncMap((event) async => await this.refresh()).listen((_) { }, onError: (_) { });
    };
    controller.onPause = () {
      stateSubscription.pause();
      refreshSubscription.pause();
    };
    controller.onResume = () {
      stateSubscription.resume();
      refreshSubscription.resume();
    };
    controller.onCancel = () {
      stateSubscription.cancel();
      refreshSubscription.cancel();
    };

    return controller.stream;
  }

  /// Wraps use-case to refresh on each subscription
  LceUseCase<DATA> refreshed() => _RefreshedLceUse(this);
}

/// Use-case mapper
class _LceUseCaseMapper<DATA extends Object, DATA_2 extends Object> implements LceUseCase<DATA_2> {
  final LceUseCase<DATA> _wrapped;
  final DATA_2 Function(DATA data) _mapper;

  const _LceUseCaseMapper(this._wrapped, this._mapper);

  @override
  Stream<LceState<DATA_2>> get state => _wrapped.state.map((state) => state.map(_mapper));

  @override
  Future<void> refresh() => _wrapped.refresh();
}

/// Use-case mapper
class _RefreshedLceUse<DATA extends Object> implements LceUseCase<DATA> {
  final LceUseCase<DATA> _wrapped;

  const _RefreshedLceUse(this._wrapped);

  @override
  Stream<LceState<DATA>> get state async* {
    await _wrapped.refresh();
    yield* _wrapped.state;
  }

  @override
  Future<void> refresh() => _wrapped.refresh();
}

/// [LceState] stream extensions
extension LceModelExtension<DATA extends Object, PARAMS extends Object> on LceModel<DATA, PARAMS> {
  /// Creates a model wrapper that converts [DATA_1] to [DATA_2]
  /// [DATA_2] Resulting data type
  /// [mapper] Data mapper
  LceModel<DATA_2, PARAMS> map<DATA_2 extends Object>(DATA_2 Function(DATA data) mapper) => _LceModelMapper<DATA, DATA_2, PARAMS>(this, mapper);
}

/// Model mapper
class _LceModelMapper<DATA extends Object, DATA_2 extends Object, PARAMS extends Object> implements LceModel<DATA_2, PARAMS> {
  final LceModel<DATA, PARAMS> _wrapped;
  final DATA_2 Function(DATA data) _mapper;

  const _LceModelMapper(this._wrapped, this._mapper);

  @override
  PARAMS get params => _wrapped.params;

  @override
  Stream<LceState<DATA_2>> get state => _wrapped.state.map((state) => state.map(_mapper));

  @override
  Future<void> refresh() => _wrapped.refresh();
}