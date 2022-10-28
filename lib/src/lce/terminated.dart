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
class Terminated extends LceState<Never> {
  @override
  // ignore: prefer_void_to_null
  final Never? data = null;

  /// [Terminated] instance
  static const instance = Terminated._private();

  /// Flow terminated state
  const Terminated._private() : super._internal(false);

  @override

  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0.hashCode;

  @override
  String toString() {
    return 'Terminated';
  }

  @override
  T when<T>({
    required T Function(Loading<Never> state) loading,
    required T Function(Content<Never> state) content,
    required T Function(Error<Never> state) error,
    T Function()? terminated
  }) {
    if (null == terminated) {
      throw UnimplementedError('Unexpected termination. Terminated handler not implemented');
    };
    return terminated();
  }

  @override
  T whenElse<T>({
    T Function(Loading<Never> state)? loading,
    T Function(Content<Never> state)? content,
    T Function(Error<Never> state)? error,
    T Function()? terminated,
    required T Function(LceState<Never> state) onElse
  }) {
    return (null != terminated) ? terminated() : onElse(this);
  }
}
