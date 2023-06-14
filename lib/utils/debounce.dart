import 'dart:async';

// This map will track all your pending function calls
Map<Function, Timer> _timeouts = {};

void debounce(Duration timeout, Function target, [List arguments = const []]) {
  if (_timeouts.containsKey(target)) {
    print(_timeouts[target]);
    _timeouts[target]?.cancel();
  }

  Timer timer = Timer(timeout, () {
    print(_timeouts[target]);
    Function.apply(target, arguments);
  });

  _timeouts[target] = timer;
}
