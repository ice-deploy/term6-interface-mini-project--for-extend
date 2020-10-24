// library screen_bed_motor;

// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../configs/configs.dart';
import '../models/models.dart';
import '../bloc/bloc.dart';

import '../widgets/widgets.dart';

// หน้าควบคุมมอเตอร์
class BedMotorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'เตียงพลิกผู้ป่วย',
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // https://stackoverflow.com/questions/49869873/flutter-update-widgets-on-resume
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      suspendingCallBack: () async {
        BlocProvider.of<JoypadBloc>(context).add(CallStopPing());
      },
    ));
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // WidgetsBinding.instance.removeObserver(this);
    print('called dispose()');

    BlocProvider.of<JoypadBloc>(context).add(CallStopPing());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.android),
          onPressed: () {
            // print('Clink: icon-1');
          },
        ),
        title: Text("เตียงพลิกผู้ป่วย"),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                print('Click setting-icon:');

                TextEditingController textEditingController =
                    TextEditingController();
                final _oldValue = MyApiWebsocket.getIP();
                String newText = await showDialog(
                  context: context,
                  builder: (context) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: MyDialogSingleInput(
                        textEditingController: textEditingController,
                        title: 'Enter New IP:',
                        labelText: 'Enter the Server IP',
                        errorText: 'Value Can\'t Be Empty',
                        actionButtonText: 'Update',
                        oldValue: _oldValue,
                      ),
                    );
                  },
                );
                if (newText == null) {
                  return;
                }

                await MyApiWebsocket.setIP(
                    'ws://${textEditingController.text}');
                // update-IP
                final newIP = MyApiWebsocket.getIP();
                print("setting New-IP: $newIP");

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated IP: $newIP'),
                    backgroundColor: Colors.green,
                  ),
                );

                BlocProvider.of<JoypadBloc>(context)
                    .add(CallUpdate_currentIP(currentIP: newIP));
              },
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 30.0),
        // color: Colors.green,
        child: Stack(children: <Widget>[
          (_isLoading)
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetJoyPad(motorName: JoyMotorName.m2IsLeft),
                      WidgetJoyPad(motorName: JoyMotorName.m1IsRight),
                    ],
                  ),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: BlocBuilder<JoypadBloc, JoypadState>(
                        condition: (previous, current) {
                      if (current is ReBuildActiveUserCount_JoypadState) {
                        return true;
                      } else if (current is LoadingStartConnectingState) {
                        return true;
                      } else {
                        return false;
                      }
                    }, builder: (BuildContext context, JoypadState state) {
                      if (state is ReBuildActiveUserCount_JoypadState) {
                        final _currentActiveUsersCount =
                            state.currentActiveUsersCount;
                        if (_currentActiveUsersCount == 'offline') {
                          // เมื่อ onErr,onDone ให้ show 'Offline'
                          return Text('Offline.');
                        } else {
                          // แสดงจำนวน ผู้ใช้ที่ Online.
                          return Text(
                              // 'Active-Users online: $_currentActiveUsersCount users.');
                              'Active-Users: $_currentActiveUsersCount users.');
                        }
                      } else if (state is LoadingStartConnectingState) {
                        return Text('Loading...');
                      }
                      return Text('Offline.');
                      // return Text('Not-Match state.');
                    }),
                  ),
                  MyListenGlobalBloc(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: MyWidgetCurrentIP(),
                  ),
                  BlocBuilder<JoypadBloc, JoypadState>(
                      condition: (previous, current) {
                    if (current is ReBuildIsConnectingState) {
                      return true;
                    } else {
                      return false;
                    }
                  }, builder: (BuildContext context, JoypadState state) {
                    final _isConnecting =
                        BlocProvider.of<JoypadBloc>(context).isConnecting;
                    return RawMaterialButton(
                      onPressed: () async {
                        if (_isConnecting) {
                          BlocProvider.of<JoypadBloc>(context)
                              .add(CallStopPing());
                        } else {
                          BlocProvider.of<JoypadBloc>(context)
                              .add(CallStartPing());
                        }
                      },
                      elevation: 2.0,
                      fillColor: (_isConnecting)
                          ? Colors.yellow[700]
                          : Colors.greenAccent,
                      child: Container(
                        padding: (_isConnecting)
                            ? EdgeInsets.all(36.0)
                            : EdgeInsets.all(28.0),
                        child: Text(
                          (_isConnecting) ? 'DisConnect' : 'Connect',
                          style: TextStyle(
                            fontSize: (_isConnecting) ? 32 : 40,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.white,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(35.0),
                      shape: CircleBorder(),
                    );
                  }),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
