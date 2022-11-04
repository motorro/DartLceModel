import 'package:mockito/mockito.dart';

/// Mockito extensions
extension When<T> on PostExpectation<T> {
  /// Each call returns [args] one by one
  /// The last elements stays there for all subsequent calls
  void thenReturnOneByOne(List<T> args) {
    assert(args.isNotEmpty, 'Argument list should not be empty!');
    thenAnswer((_) => 1 == args.length ? args[0] : args.removeAt(0));
  }
}

extension WhenFuture<T> on PostExpectation<Future<T>> {
  /// Each call returns [args] one by one
  /// The last elements stays there for all subsequent calls
  void thenReturnOneByOne(List<T> args) {
    assert(args.isNotEmpty, 'Argument list should not be empty!');
    thenAnswer((_) => 1 == args.length ? Future.value(args[0]) : Future.value(args.removeAt(0)));
  }
}