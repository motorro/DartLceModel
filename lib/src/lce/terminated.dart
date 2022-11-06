part of './lcestate.dart';

/// A special state that may be used to terminate state emission in cases we always need a latest state to proceed
/// For example we have a view that subscribes to [LceState] for a resource identified with some PARAMS.
/// Than a delete operation is performed on that resource and it is not available anymore.
/// The one may emit [Terminated] to do a special processing (e.g. close the corresponding view) instead of
/// doing it through server request that will return a `Not found` error and doing a special case
/// processing afterwards.
/// Also useful when `onComplete` from state-emitter can't be processed by the end-subscriber. For example LiveData
/// does not emit completion and caches the latest emission. So converting stream to LiveData will loose Rx completion
/// logic.
class Terminated<DATA extends Object> extends LceState<DATA> {
  @override
  final DATA? data = null;

  /// Flow terminated state
  const Terminated() : super._internal(false);

  @override

  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Terminated &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'Terminated';
  }

  @override
  T when<T extends Object>({
    required T Function(Loading<DATA> state) loading,
    required T Function(Content<DATA> state) content,
    required T Function(Error<DATA> state) error,
    T Function()? terminated
  }) {
    if (null == terminated) {
      throw UnimplementedError('Unexpected termination. Terminated handler not implemented');
    };
    return terminated();
  }

  @override
  T whenElse<T extends Object>({
    T Function(Loading<DATA> state)? loading,
    T Function(Content<DATA> state)? content,
    T Function(Error<DATA> state)? error,
    T Function()? terminated,
    required T Function(LceState<DATA> state) onElse
  }) {
    return terminated?.call() ?? onElse(this);
  }
}
