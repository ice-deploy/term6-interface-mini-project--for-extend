import 'dart:async';
import 'package:bloc/bloc.dart';

// import '../configs/configs.dart';
import '../models/models.dart';

import './bloc.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  @override
  GlobalState get initialState => InitialGlobalState();

  @override
  Stream<GlobalState> mapEventToState(
    GlobalEvent event,
  ) async* {
    print('event is: $event');
    print('previous-state is: $state');
    if (event is CallStarter) {
      // load Shared-preference -> lastIP
      await MyApiWebsocket.initIP();
      yield GotoExControlPadState();
    } else if (event is CallShowErrorToUI) {
      yield ShowErrorState(message: event.message);
    } else if (event is CallShowWarningToUI) {
      yield ShowWarningState(message: event.message);
    }

    // สร้างความแตกต่าง(state)
    yield LoadedGlobalState();
  }
}
