import 'dart:async';
import 'package:bedmotor_with_http/configs/configs.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import '../models/models.dart';

import './bloc.dart';

class JoypadBloc extends Bloc<JoypadEvent, JoypadState> {
  final GlobalBloc globalBloc;
  bool isConnecting = false;
  // int _currentPING = 0;
  Timer _subscription;

  JoypadBloc({@required this.globalBloc});

  @override
  JoypadState get initialState => InitialJoypadState();

  @override
  Stream<JoypadState> mapEventToState(
    JoypadEvent event,
  ) async* {
    yield LoadingState();
    if (event is CallUpdateIsConnecting) {
      // update-when-only-Change 'isConnecting'.isChange
      if (event.isConnecting != isConnecting) {
        isConnecting = event.isConnecting;
        yield ReBuildIsConnectingState();
      }
    } else if (event is CallStartPing) {
      yield LoadingStartConnectingState(); //แสดง Loding-Progress...
      await _startConnecting();
      yield ReBuildIsConnectingState(); // End Loding-Progress.
    } else if (event is CallStopPing) {
      await _stopConnecting();
      yield ReBuildIsConnectingState();
    } else if (event is CallUpdatePing) {
      final stopTime = DateTime.now().millisecondsSinceEpoch;
      yield UpdatePingUIState(
          status: 'success',
          pingTimeCount: event.pingTimeCount,
          timeStamp: stopTime);
    } else if (event is DebugOnlyJoypadEvent) {
      print('event is DebugOnlyJoypadEvent');
    }
    yield LoadedState();
  }

  _stopConnecting() async {
    //stop timer
    if (_subscription != null) {
      if (_subscription.isActive) {
        _subscription.cancel();
      }
    }
    // isConnecting = false;
    add(CallUpdateIsConnecting(isConnecting: false));
  }

  _startConnecting() async {
    //stop before-start
    if (_subscription != null) {
      if (_subscription.isActive) {
        _subscription.cancel();
      }
    }
    isConnecting = true;
    add(CallUpdateIsConnecting(isConnecting: true));
    await _pingOneTime();
    //start timer
    _subscription =
        Timer.periodic(const Duration(seconds: 1), (val) => _pingOneTime());
  }

  _pingOneTime() async {
    // NOTE: run-onlt _isConnecting == true
    if (isConnecting) {
      // call-API (pingCheck)
      final String path = ConfigsApiPath.pathHello;

      // capture pingTimeCount
      final startTime = DateTime.now().millisecondsSinceEpoch;
      final bool isCalledApi = await MyApiDio.motorApi(path);
      final stopTime = DateTime.now().millisecondsSinceEpoch;
      final int pingTimeCount = stopTime - startTime;
      add(CallUpdatePing(pingTimeCount: pingTimeCount));

      if (!isCalledApi) {
        // check-Err
        await _stopConnecting();
        globalBloc.add(CallShowErrorToUI(
            message: 'Cannot connect[_pingOneTime()] to server!!'));
      }
    } else {
      await _stopConnecting();
    }
  }
}
