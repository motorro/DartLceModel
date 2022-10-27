/// Time provider
abstract class Clock {
  // System clock
  static const system = _SystemClock();

  const Clock();

  /// Current milliseconds value
  int getMillis();
}

// System clock
class _SystemClock extends Clock {

  const _SystemClock();

  @override
  int getMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}