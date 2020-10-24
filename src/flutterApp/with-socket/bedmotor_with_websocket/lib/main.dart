import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';

import 'configs/configs.dart';
import 'screens/screens.dart';

//single screen-version(with-websocket)

// DEPLOY:
// flutter build apk --target-platform android-arm64
//or-PC
// -// flutter build apk --target-platform android-x64

// flutter wifi permission
// https://flutter.dev/docs/development/data-and-backend/networking
// android\app\src\main\AndroidManifest.xml
/*
<uses-permission android:name="android.permission.INTERNET" />
*/

void main() {
  return runApp(
    BlocProvider(
      create: (BuildContext context) {
        return GlobalBloc()..add(CallStarter());
      },
      child: MyBlocApp(),
    ),
  );
}

class MyBlocApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'bedmotor_with_websocket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: NavRoutes.mainScreen,
      routes: {
        NavRoutes.mainScreen: (context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: MySplashScreen(),
          );
        },
        NavRoutes.exControlPad: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<JoypadBloc>(
                create: (context) {
                  return JoypadBloc(
                    globalBloc: BlocProvider.of<GlobalBloc>(context),
                  );
                },
              ),
            ],
            child: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: BedMotorScreen(),
            ),
          );
        },
      },
    );
  }
}
