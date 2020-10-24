import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class GlobalState extends Equatable {
  const GlobalState();
}

class InitialGlobalState extends GlobalState {
  @override
  List<Object> get props => [];
}

class GotoExControlPadState extends GlobalState {
  @override
  List<Object> get props => [];
}

class ShowErrorState extends GlobalState {
  final message;

  ShowErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}

class LoadedGlobalState extends GlobalState {
  @override
  List<Object> get props => [];
}
