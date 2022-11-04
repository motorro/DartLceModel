
/// Refresh command to send through [refreshChannel]
abstract class CacheServiceCommand<P extends Object> {
  /// Called by actor to check if the command concerns him
  bool isForMe(P params);

  /// Emulates sealed class with every state callback required
  T when<T>({
    required T Function(Individual<P> state) individual,
    required T Function() all
  });
}

/// Refreshes actor with bound [params]
class Individual<P extends Object> implements CacheServiceCommand<P> {
  final P _params;

  const Individual(this._params);

  @override
  bool isForMe(P params) {
    return params == _params;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Individual &&
              runtimeType == other.runtimeType &&
              _params == other._params;

  @override
  int get hashCode => "_Individual".hashCode ^ _params.hashCode;

  @override
  String toString() {
    return '_Individual{_params: $_params}';
  }

  @override
  T when<T>({
    required T Function(Individual<P> state) individual,
    required T Function() all
  }) => individual(this);
}

/// Refreshes all actors
class All<P extends Object> implements CacheServiceCommand<P> {

  const All();

  @override
  bool isForMe(P params) {
    return true;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is All;

  @override
  int get hashCode => "_All".hashCode;

  @override
  String toString() => '_All';

  @override
  T when<T>({
    required T Function(Individual<Never> state) individual,
    required T Function() all
  }) => all();
}
