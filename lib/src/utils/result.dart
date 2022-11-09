
/// Operation result.
/// Either [ok] or [error]
abstract class Result<D> {
  const factory Result.ok(D data) = _Ok;
  const factory Result.error(Exception error) = _Error;

  /// Checks the result type
  /// [ok] - Result handler
  /// [error] - Error handler
  T when<T>({ required T Function(D) ok, required T Function(Exception) error });
}

class _Ok<D> implements Result<D> {
  final D data;
  const _Ok(this.data);

  @override
  T when<T>({ required T Function(D) ok, required T Function(Exception) error }) {
    return ok(data);
  }
}

class _Error<D> implements Result<D> {
  final Exception error;
  const _Error(this.error);

  @override
  T when<T>({ required T Function(D) ok, required T Function(Exception) error }) {
    return error(this.error);
  }
}

/// Converts [Future] and returns [Result]
extension ToResult<D> on Future<D> {
  /// Converts [Future] and returns [Result]
  Future<Result<D>> toResult() =>
      then((value) => Result.ok(value))
      .catchError((error) => error is Exception ? Result<D>.error(error) : Result<D>.error(Exception(error)));
}

/// Converts [Result] to [Future]
extension ToFuture<D> on Result<D> {
  /// Converts [Result] to [Future]
  Future<D> toFuture() => when(ok: (data) => Future<D>.value(data), error: (error) => Future.error(error));
}
