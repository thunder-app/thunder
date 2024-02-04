import 'package:flutter/material.dart';

class GlobalContext {
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static BuildContext get context => scaffoldMessengerKey.currentContext!;
}
