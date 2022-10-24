part "./content.dart";
part "./error.dart";
part "./loading.dart";
part "./terminated.dart";

/// State for "Loading-Content-Error" resource which retrieves [DATA]
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
  const factory LceState.loading(DATA? data, bool dataIsValid, [ LoadingType type ]) = Loading;

  /// [DATA] is loaded
  /// [data] State data
  /// [dataIsValid] Data validity at the time of emission
  const factory LceState.content(DATA data, bool dataIsValid) = Content;

  /// [DATA] load error. May contain some [data] if cached
  /// [data] State data
  /// [dataIsValid] Data validity at the time of emission
  /// [error] Error occurred
  const factory LceState.error(DATA data, bool dataIsValid, Exception error) = Error;

  /// Creates a terminating state that signals emission finish
  const factory LceState.terminated() = Terminated;

  /// Transfers to [Loading] state with loading [type] preserving data
  Loading<DATA> toLoading([ LoadingType type = LoadingType.loading ]) {
    return Loading(data, dataIsValid, type);
  }

  /// Transfers to [Error] state with [error] preserving data
  Error<DATA> toError(Exception error) {
    return Error(data, dataIsValid, error);
  }

  T when<T extends Object>({
    required T Function(Loading<DATA> state) loading,
    required T Function(Content<DATA> state) content,
    required T Function(Error<DATA> state) error,
    T Function()? terminated
  });
}
