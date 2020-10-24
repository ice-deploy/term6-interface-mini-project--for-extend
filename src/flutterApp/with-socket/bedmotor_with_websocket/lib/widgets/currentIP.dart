import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../models/api.dart';

class MyWidgetCurrentIP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JoypadBloc, JoypadState>(condition: (previous, current) {
      print('condition ->previous, current: $previous, $current');
      if (current is ReBuild_currentIP) {
        return true;
      } else {
        return false;
      }
    }, builder: (BuildContext context, JoypadState state) {
      if (state is ReBuild_currentIP) {
        final _currentIP = state.currentIP;
        return Text('IP: $_currentIP');
      }
      final _currentIP = MyApiWebsocket.getIP();
      return Text('IP: $_currentIP');
    });
  }
}
