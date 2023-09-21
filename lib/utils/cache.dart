/// Defines a cache class which can be used to store values in memory for a certain [expiration]
/// or else re-fetch the value using the given [getValue] function.
class Cache<T> {
  T getOrSet(T Function() getValue, Duration expiration) {
    if (_value == null || (_lastSetTime ?? DateTime.fromMicrosecondsSinceEpoch(0)).add(expiration).isBefore(DateTime.now())) {
      _value = getValue();
      _lastSetTime = DateTime.now();
    }
    return _value!;
  }

  T? _value;
  DateTime? _lastSetTime;
}
