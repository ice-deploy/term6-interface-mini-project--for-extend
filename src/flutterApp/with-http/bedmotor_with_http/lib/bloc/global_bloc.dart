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
    if (event is CallStarter) {
      // load Shared-preference -> lastIP
      await MyApiDio.initIP();
      yield GotoExControlPadState();
    } else if (event is CallShowErrorToUI) {
      yield ShowErrorState(message: event.message);
    }
    yield LoadedGlobalState();
  }
}
