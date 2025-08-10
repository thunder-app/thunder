import 'dart:async';

// This map will track all your pending function calls
Map<Function, Timer> _timeouts = {};

void debounce(Duration timeout, Function target, [List arguments = const []]) {
  if (_timeouts.containsKey(target)) {
    _timeouts[target]?.cancel();
  }

  Timer timer = Timer(timeout, () {
    Function.apply(target, arguments);
  });

  _timeouts[target] = timer;
}
