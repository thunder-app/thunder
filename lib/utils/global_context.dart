import 'package:flutter/material.dart';

class GlobalContext {
  static GlobalKey overlayKey = GlobalKey();
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static BuildContext get context => scaffoldMessengerKey.currentContext!;
}
