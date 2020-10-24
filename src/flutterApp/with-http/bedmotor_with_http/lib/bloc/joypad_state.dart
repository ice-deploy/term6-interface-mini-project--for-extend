import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class JoypadState extends Equatable {
  const JoypadState();
}

class InitialJoypadState extends JoypadState {
  @override
  List<Object> get props => [];
}

class LoadingState extends JoypadState {
  @override
  List<Object> get props => [];
}

class LoadedState extends JoypadState {
  @override
  List<Object> get props => [];
}

class UpdatePingUIState extends JoypadState {
  final String status;
  final int pingTimeCount;
  final int timeStamp;

  UpdatePingUIState(
      {@required this.status,
      @required this.pingTimeCount,
      @required this.timeStamp});

  @override
  List<Object> get props => [status, pingTimeCount, timeStamp];
}

class LoadingStartConnectingState extends JoypadState {
  @override
  List<Object> get props => [];
}

class ReBuildIsConnectingState extends JoypadState {
  @override
  List<Object> get props => [];
}
