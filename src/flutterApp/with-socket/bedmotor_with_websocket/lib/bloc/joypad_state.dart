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

class ReBuildActiveUserCount_JoypadState extends JoypadState {
  final String currentActiveUsersCount;

  ReBuildActiveUserCount_JoypadState({
    @required this.currentActiveUsersCount,
  });

  @override
  List<Object> get props => [currentActiveUsersCount];
}

class LoadingStartConnectingState extends JoypadState {
  @override
  List<Object> get props => [];
}

class ReBuildIsConnectingState extends JoypadState {
  @override
  List<Object> get props => [];
}

class ReBuild_currentIP extends JoypadState {
  final String currentIP;

  ReBuild_currentIP({
    @required this.currentIP,
  });

  @override
  List<Object> get props => [
        currentIP,
      ];
}
