part of "./lcestate.dart";

/// [DATA] load error. May contain some [data] if cached
/// [data] State data
/// [dataIsValid] Data validity at the time of emission
/// [error] Error occurred
class Error<DATA extends Object> extends LceState<DATA> {
  @override
  final DATA? data;

  // Error occurred
  final Exception error;

  /// [DATA] load error. May contain some [data] if cached
  /// [data] State data
  /// [dataIsValid] Data validity at the time of emission
  /// [error] Error occurred
  const Error(this.data, bool dataIsValid, this.error) : super._internal(dataIsValid);

  Error<DATA> copyWith({ DATA? data, bool? dataIsValid, Exception? error }) {
    return Error(
        data ?? this.data,
        dataIsValid ?? this.dataIsValid,
        error ?? this.error
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Error &&
              runtimeType == other.runtimeType &&
              data == other.data &&
              dataIsValid == other.dataIsValid &&
              error == other.error;

  @override
  int get hashCode => data.hashCode ^ dataIsValid.hashCode ^ error.hashCode;

  @override
  String toString() {
    return 'Error{data: $data, dataIsValid: $dataIsValid, error: $error}';
  }

  @override
  T when<T extends Object>({
    required T Function(Loading<DATA> state) loading,
    required T Function(Content<DATA> state) content,
    required T Function(Error<DATA> state) error,
    T Function()? terminated
  }) {
    return error(this);
  }
}
