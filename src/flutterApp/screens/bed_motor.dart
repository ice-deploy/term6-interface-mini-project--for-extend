import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bedmotor/widgets/widgets.dart';
import 'package:bedmotor/configs/configs.dart';
import 'package:bedmotor/models/models.dart';

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

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  String _currentIP = MyApiDio.getIP();

// https://stackoverflow.com/questions/50322054/flutter-how-to-set-and-lock-screen-orientation-on-demand
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

                print("Enter project_name");
                TextEditingController textEditingController =
                    TextEditingController();
                String projectNameLocal = await showDialog(
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
                      ),
                    );
                  },
                );
                print(projectNameLocal);
                if (projectNameLocal == null) {
                  return;
                }

                MyApiDio.setIP('http://${textEditingController.text}');
                final newIP = MyApiDio.getIP();
                print("setting New-IP: $newIP");

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated IP: $newIP'),
                    backgroundColor: Colors.green,
                  ),
                );

                setState(() {
                  _currentIP = newIP;
                });
              },
            ),
          ),
        ],
      ),
      body: Container(
        // padding: EdgeInsets.only(bottom: 20),
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
                    child: Text('IP: $_currentIP'),
                  ),
                  RawMaterialButton(
                    onPressed: () async {
                      if (_isLoading) {
                        return;
                      }
                      // MyApiDio.checkServer();
                      bool isCalledApi = await MyApiDio.stop();
                      if (isCalledApi != true) {
                        return;
                      }
                      setState(() {
                        _isLoading = true;
                      });
                      Future.delayed(Duration(seconds: 3)).then((value) {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    },
                    elevation: 2.0,
                    fillColor:
                        (_isLoading) ? Colors.blueGrey : Colors.redAccent,
                    child: Text(
                      'ฉุกเฉิน',
                      style: TextStyle(
                        fontSize: 40,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          // ..color = Colors.blue[700],
                          ..color = Colors.white,
                      ),
                    ),
                    padding: EdgeInsets.all(35.0),
                    shape: CircleBorder(),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
