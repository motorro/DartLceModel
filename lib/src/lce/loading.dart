part of './lce_state.dart';

/// [DATA] is loading
/// [data] is the current data if any
/// [dataIsValid] Data validity at the time of emission
/// [type] Loading type
class LceLoading<DATA extends Object> extends LceState<DATA> {
  @override
  final DATA? data;

  // Loading type
  final LoadingType type;

  /// Data is loading
  /// [data] is the current data if any
  /// [dataIsValid] Data validity at the time of emission
  /// [type] Loading type
  const LceLoading(this.data, bool dataIsValid, [ this.type = LoadingType.loading ]) : super._internal(dataIsValid);

  LceLoading<DATA> copyWith({ DATA? data, bool? dataIsValid, LoadingType? type}) {
    return LceLoading(
        data ?? this.data,
        dataIsValid ?? this.dataIsValid,
        type ?? this.type
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LceLoading &&
              runtimeType == other.runtimeType &&
              data == other.data &&
              dataIsValid == other.dataIsValid &&
              type == other.type;

  @override
  int get hashCode => data.hashCode ^ dataIsValid.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'Loading{data: $data, dataIsValid: $dataIsValid, type: $type}';
  }

  @override
  T when<T extends Object>({
    required T Function(LceLoading<DATA> state) loading,
    required T Function(LceContent<DATA> state) content,
    required T Function(LceError<DATA> state) error,
    T Function()? terminated
  }) {
    return loading(this);
  }

  @override
  T whenElse<T extends Object>({
    T Function(LceLoading<DATA> state)? loading,
    T Function(LceContent<DATA> state)? content,
    T Function(LceError<DATA> state)? error,
    T Function()? terminated,
    required T Function(LceState<DATA> state) onElse
  }) {
    return loading?.call(this) ?? onElse(this);
  }
}

/// Loading type
enum LoadingType {
  /// Just loads. May be initial load operation
  loading,
  /// Loading more items for paginated view
  loadingMore,
  /// Refreshing content
  refreshing,
  /// Updating data on server
  updating
}
