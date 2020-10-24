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

class CallUpdatePing extends JoypadEvent {
  final pingTimeCount;

  CallUpdatePing({@required this.pingTimeCount});

  @override
  List<Object> get props => [pingTimeCount];
}
