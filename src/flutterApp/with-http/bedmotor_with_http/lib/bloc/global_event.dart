import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class GlobalEvent extends Equatable {
  const GlobalEvent();
}

class CallStarter extends GlobalEvent {
  CallStarter();

  @override
  List<Object> get props => null;
}

class CallShowErrorToUI extends GlobalEvent {
  final message;

  CallShowErrorToUI({@required this.message});

  @override
  List<Object> get props => [message];
}
