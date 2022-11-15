part of './lce_state.dart';

/// [DATA] is loaded
/// [data] State data
/// [dataIsValid] Data validity at the time of emission
class LceContent<DATA extends Object> extends LceState<DATA> {
  @override
  final DATA data;

  /// [DATA] is loaded
  /// [data] State data
  /// [dataIsValid] Data validity at the time of emission
  const LceContent(this.data, bool dataIsValid) : super._internal(dataIsValid);

  LceContent<DATA> copyWith({ DATA? data, bool? dataIsValid }) {
    return LceContent(
        data ?? this.data,
        dataIsValid ?? this.dataIsValid
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LceContent &&
              runtimeType == other.runtimeType &&
              data == other.data &&
              dataIsValid == other.dataIsValid;

  @override
  int get hashCode => data.hashCode ^ dataIsValid.hashCode;

  @override
  String toString() {
    return 'Content{data: $data, dataIsValid: $dataIsValid}';
  }

  @override
  T when<T extends Object>({
    required T Function(LceLoading<DATA> state) loading,
    required T Function(LceContent<DATA> state) content,
    required T Function(LceError<DATA> state) error,
    T Function()? terminated
  }) {
    return content(this);
  }

  @override
  T whenElse<T extends Object>({
    T Function(LceLoading<DATA> state)? loading,
    T Function(LceContent<DATA> state)? content,
    T Function(LceError<DATA> state)? error,
    T Function()? terminated,
    required T Function(LceState<DATA> state) onElse
  }) {
    return content?.call(this) ?? onElse(this);
  }
}
