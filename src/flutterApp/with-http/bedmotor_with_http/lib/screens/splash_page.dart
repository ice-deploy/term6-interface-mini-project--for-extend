import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../configs/configs.dart';

class MySplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<GlobalBloc, GlobalState>(
          listener: (BuildContext context, GlobalState state) {
            print('GlobalBloc - listener -> state: $state');
            if (state is GotoExControlPadState) {
              Navigator.pushReplacementNamed(context, NavRoutes.exControlPad);
            }
          },
          child: Text('Splash Screen'),
        ),
      ),
    );
  }
}
