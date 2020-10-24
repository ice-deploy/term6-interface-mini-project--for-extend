import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class JoypadEvent extends Equatable {
  const JoypadEvent();
}

class DebugOnlyJoypadEvent extends JoypadEvent {
  @override
  List<Object> get props => null;
}

class CallStartPing extends JoypadEvent {
  @override
  List<Object> get props => null;
}

class CallStopPing extends JoypadEvent {
  @override
  List<Object> get props => null;
}

class CallUpdateIsConnecting extends JoypadEvent {
  final isConnecting;

  CallUpdateIsConnecting({@required this.isConnecting});

  @override
  List<Object> get props => [isConnecting];
}

class CallUpdateActiveUser extends JoypadEvent {
  final String currentActiveUsers;

  CallUpdateActiveUser({@required this.currentActiveUsers});

  @override
  List<Object> get props => [currentActiveUsers];
}

class CallUpdate_currentIP extends JoypadEvent {
  final currentIP;

  CallUpdate_currentIP({@required this.currentIP});

  @override
  List<Object> get props => [currentIP];
}

// local Event

class LocalCallApi_sendDataOnly extends JoypadEvent {
  final command;
  LocalCallApi_sendDataOnly({@required this.command});

  @override
  List<Object> get props => [command];
}
