import 'package:flutter/cupertino.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  static bool isAppForeground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    isAppForeground = state == AppLifecycleState.resumed;
  }
}