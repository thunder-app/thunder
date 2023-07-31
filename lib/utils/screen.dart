import 'package:flutter/material.dart';

/// Returns the available screen height without including OS elements such as the status bar and the nav bar
/// From: https://stackoverflow.com/a/71895304/4206279
double getScreenHeightWithoutOs(BuildContext context) => MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top - kBottomNavigationBarHeight;
