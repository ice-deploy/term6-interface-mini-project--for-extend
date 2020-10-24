import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        print('resumed.');
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
        print('inactive.');
        break;
      case AppLifecycleState.paused:
        print('paused.');
        break;
      case AppLifecycleState.detached:
        print('detached.');
        try {
          if (suspendingCallBack != null) {
            await suspendingCallBack();
          }
        } catch (e) {
          print('Err: detached.');
          print(e);
        }
        break;
    }
  }
}
