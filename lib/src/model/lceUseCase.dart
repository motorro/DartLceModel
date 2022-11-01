/// Base LCE use-case with [state] and [refresh]
/// [DATA] Data type of data being loaded
abstract class LceUseCase<DATA extends Object> {
  /// Model state. Subscription starts data load for the first subscriber.
  /// Whenever last subscriber cancels, the model unsubscribes internal components for data updates
  abstract Stream<DATA> state;

  /// Requests a refresh of data.
  /// Data will be updated asynchronously
  Future<void> refresh();
}