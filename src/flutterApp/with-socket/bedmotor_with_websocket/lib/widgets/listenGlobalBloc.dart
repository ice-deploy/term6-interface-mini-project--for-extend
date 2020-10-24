import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class MyListenGlobalBloc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('build: MyListenGlobalBloc');
    return BlocListener<GlobalBloc, GlobalState>(
      listener: (BuildContext context, GlobalState state) {
        print('run: MyListenGlobalBloc');
        // NOTE: จัดการ State ของ GlobalBloc
        if (state is ShowErrorState) {
          if (state.message != null) {
            // show-snackBar message-err [from GlobalBloc].
            final String _local_message = state.message;
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(_local_message),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // ส่งข้อความ null มาเฉย
            print('(ShowErrorState)ส่งข้อความ null มาเฉย');
          }
        } else if (state is ShowWarningState) {
          if (state.message != null) {
            // show-snackBar message-err [from GlobalBloc].
            final String _local_message = state.message;
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(_local_message),
                backgroundColor: Colors.yellow[900],
              ),
            );
          } else {
            // ส่งข้อความ null มาเฉย
            print('(ShowWarningState)ส่งข้อความ null มาเฉย');
          }
        }
      },
      // NOTE: null-Widget
      // https://stackoverflow.com/questions/53455358/how-to-present-an-empty-view-in-flutter
      // child: SizedBox.shrink(),
      // child: SizedBox(width: 0, height: 0),
      child: Container(
        color: Colors.green,
      ),
    );
  }
}
