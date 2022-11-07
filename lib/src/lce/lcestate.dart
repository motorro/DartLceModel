part './content.dart';
part './error.dart';
part './loading.dart';
part './terminated.dart';

/// State for 'Loading-Content-Error' resource which retrieves [DATA]
abstract class LceState<DATA extends Object> {
  /// State data
  abstract final DATA? data;

  /// A property that is evaluated internally and may mean that data being emitted is stall,
  /// invalidated or otherwise 'not-so-valid' until some further emission (say after network
  /// reload).
  final bool dataIsValid;

  const LceState._internal(this.dataIsValid);

  /// [DATA] is loading
  /// [data] is the current data if any
  /// [dataIsValid] Data validity at the time of emission
  /// [type] Loading type
  const factory LceState.loading(DATA? data, bool dataIsValid, [ LoadingType type ]) = LceLoading;

  /// [DATA] is loaded
  /// [data] State data
  /// [dataIsValid] Data validity at the time of emission
  const factory LceState.content(DATA data, bool dataIsValid) = LceContent;

  /// [DATA] load error. May contain some [data] if cached
  /// [data] State data
  /// [dataIsValid] Data validity at the time of emission
  /// [error] Error occurred
  const factory LceState.error(DATA? data, bool dataIsValid, Exception error) = LceError;

  /// Creates a terminating state that signals emission finish
  const factory LceState.terminated() = LceTerminated;

  /// Transfers to [LceLoading] state with loading [type] preserving data
  LceLoading<DATA> toLoading([ LoadingType type = LoadingType.loading ]) {
    return LceLoading(data, dataIsValid, type);
  }

  /// Transfers to [LceError] state with [error] preserving data
  LceError<DATA> toError(Exception error) {
    return LceError(data, dataIsValid, error);
  }

  /// Emulates sealed class with every state callback required except
  /// [terminated]. Override it if you expect termination or leave empty
  /// to throw exception
  T when<T extends Object>({
    required T Function(LceLoading<DATA> state) loading,
    required T Function(LceContent<DATA> state) content,
    required T Function(LceError<DATA> state) error,
    T Function()? terminated
  });

  /// Emulates sealed class with only one [onElse] callback required.
  /// Every unset callback will be routed to [onElse] case.
  T whenElse<T extends Object>({
    T Function(LceLoading<DATA> state)? loading,
    T Function(LceContent<DATA> state)? content,
    T Function(LceError<DATA> state)? error,
    T Function()? terminated,
    required T Function(LceState<DATA> state) onElse
  });
}
