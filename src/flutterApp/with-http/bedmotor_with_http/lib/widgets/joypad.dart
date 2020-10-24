import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_pad/control_pad.dart';

import 'package:bedmotor_with_http/configs/configs.dart';
import 'package:bedmotor_with_http/models/models.dart';
import 'package:bedmotor_with_http/bloc/bloc.dart';

class WidgetJoyPad extends StatefulWidget {
  final JoyApiModel motorName;

  const WidgetJoyPad({Key key, @required this.motorName}) : super(key: key);

  @override
  _WidgetJoyPadState createState() => _WidgetJoyPadState();
}

class _WidgetJoyPadState extends State<WidgetJoyPad> {
  double _tempDistance = 0.0;
  bool _isMouseDOWN = false;

  bool _isConnecting;

  // onStateMotorChange
  String _lastStateMotor;

  @override
  void initState() {
    super.initState();

    _isConnecting = BlocProvider.of<JoypadBloc>(context).isConnecting;
  }

  _onStateMotorChange(currentStateMotor) async {
    if (_isMouseDOWN && _lastStateMotor != null) {
      // check mouseDown
      if (!_isMouseDOWN) {
        return;
      }
      final path =
          '${ConfigsApiPath.pathPrefixMotorControl}${widget.motorName.arrow}$currentStateMotor';
      bool isCalledApi = await MyApiDio.motorApi(path);
      if (!isCalledApi) {
        // if Err-call-stop
        BlocProvider.of<JoypadBloc>(context).add(CallStartPing());
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot connect[_onStateMotorChange()] to server!!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Call API: $path');
    } else {
      print('Err _onStateMotorChange(...)!!');
    }
  }

  void _motorStop() async {
    print('run: _motorStop()');
    final path =
        '${ConfigsApiPath.pathPrefixMotorControl}${widget.motorName.arrow}${JoyActions.stop}';
    bool isCalledApi = await MyApiDio.motorApi(path);
    if (!isCalledApi) {
      // if Err-call-stop
      BlocProvider.of<JoypadBloc>(context).add(CallStartPing());
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot connect[_motorStop()] to server!!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 20),
            // color: Colors.purple,
            child: Text(widget.motorName.text),
          ),
          BlocListener<JoypadBloc, JoypadState>(
              listener: (BuildContext context, JoypadState state) {
                if (state is ReBuildIsConnectingState) {
                  setState(() {
                    _isConnecting =
                        BlocProvider.of<JoypadBloc>(context).isConnecting;
                  });
                }
              },
              child: Listener(
                onPointerDown: (PointerEvent details) {
                  if (!_isConnecting) {
                    return;
                  }
                  print('start Call API:');
                  _isMouseDOWN = true;
                },
                onPointerUp: (PointerEvent details) {
                  if (!_isConnecting) {
                    return;
                  }
                  print('STOP Call API.');
                  _isMouseDOWN = false;
                  _motorStop();
                },
                child: JoystickView(
                  opacity: (_isConnecting) ? 1.0 : 0.5,
                  size: 150.0,
                  showArrows: false,
                  // onDirectionChanged: (degree, direction) {
                  onDirectionChanged: (degrees, distance) {
                    if (!_isConnecting) {
                      return;
                    }
                    if (_tempDistance == 0.0) {
                      _tempDistance = distance;
                      return;
                    }
                    String data =
                        "Degree : ${degrees.toStringAsFixed(2)}, distance : ${distance.toStringAsFixed(2)}";
                    if (distance > (_tempDistance + 0.07) || distance > 0.9) {
                      // debug-positionJoy
                      print(data);
                      if ((degrees > 300 && degrees < 361) ||
                          (degrees > 0 && degrees < 60)) {
                        print('UP:');
                        if (_lastStateMotor != JoyActions.up) {
                          _onStateMotorChange(JoyActions.up);
                        }
                        _lastStateMotor = JoyActions.up;
                      } else if (degrees > 120 && degrees < 250) {
                        print('DOWN:');
                        if (_lastStateMotor != JoyActions.down) {
                          _onStateMotorChange(JoyActions.down);
                        }
                        _lastStateMotor = JoyActions.down;
                      }
                      _tempDistance = distance;
                    } else if (distance < (_tempDistance - 0.07)) {
                      _tempDistance = distance;
                      print('isLower. Cancle:');
                      _motorStop();
                    }
                  },
                ),
              )),
        ],
      ),
    );
  }
}
