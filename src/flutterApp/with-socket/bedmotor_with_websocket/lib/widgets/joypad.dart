import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_pad/control_pad.dart';

import '../configs/configs.dart';
import '../models/models.dart';
import '../bloc/bloc.dart';

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

  // use-for onStateMotorChange
  String _lastStateMotor;

  @override
  void initState() {
    super.initState();

    _isConnecting = BlocProvider.of<JoypadBloc>(context).isConnecting;
  }

  _onStateMotorChange(currentStateMotor) async {
    // JoyActions.[...]
    if (_isMouseDOWN && _lastStateMotor != null) {
      // currentStateMotor = JoyActions.[...]
      // check mouseDown
      // ไม่ได้กด แล้วเกิด Event ได้ไง
      if (!_isMouseDOWN) {
        return;
      }
      final command = '${widget.motorName.arrow}$currentStateMotor';
      if (_lastStateMotor == command) {
        // ป้องกัน Widget เรียก Event รัวๆ
        return;
      }
      BlocProvider.of<JoypadBloc>(context)
          .add(LocalCallApi_sendDataOnly(command: command));
      _lastStateMotor = command;

      print('Call API: $command');
    } else {
      print('Err _onStateMotorChange(...)!!');
    }
  }

  void _motorStop() async {
    final command = '${widget.motorName.arrow}${JoyActions.stop}';
    if (_lastStateMotor == command) {
      // ป้องกัน Widget เรียก Event รัวๆ
      return;
    }
    BlocProvider.of<JoypadBloc>(context)
        .add(LocalCallApi_sendDataOnly(command: command));
    _lastStateMotor = command;
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
                // NOTE: disable เมื่อไม่ connect
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
                  print('STOP Call API. (_isMouseDOWN = false)');
                  _isMouseDOWN = false;
                  _motorStop();
                },
                child: JoystickView(
                  opacity: (_isConnecting) ? 1.0 : 0.5,
                  size: 150.0,
                  showArrows: false,
                  onDirectionChanged: (degrees, distance) {
                    if (!_isConnecting) {
                      return;
                    }
                    if (_tempDistance == 0.0) {
                      _tempDistance = distance;
                      return;
                    }
                    if (distance > (_tempDistance + 0.07) || distance > 0.9) {
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
