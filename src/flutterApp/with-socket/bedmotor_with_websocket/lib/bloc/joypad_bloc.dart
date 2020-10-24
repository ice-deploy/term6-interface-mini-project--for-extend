import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'dart:convert' as convert;

// import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

// import '../configs/configs.dart';
import '../models/models.dart';
import './bloc.dart';

class JoypadBloc extends Bloc<JoypadEvent, JoypadState> {
  final GlobalBloc globalBloc;
  bool isConnecting = false;

  String _currentConnection_ID;
  // WebSocketChannel channel;
  IOWebSocketChannel channel;

  JoypadBloc({@required this.globalBloc});

  @override
  JoypadState get initialState => InitialJoypadState();

  @override
  Stream<JoypadState> mapEventToState(
    JoypadEvent event,
  ) async* {
    if (event is CallUpdateIsConnecting) {
      // update-when-only-Change 'isConnecting'.isChange
      if (event.isConnecting != this.isConnecting) {
        print('isConnecting change...: ${event.isConnecting}');
        this.isConnecting = event.isConnecting;
        yield LoadingState(); //สร้าง State-Chang เฉยๆ
        yield ReBuildIsConnectingState();
        if (event.isConnecting == false) {
          add(CallUpdateActiveUser(currentActiveUsers: 'offline'));
        }
      }
      yield LoadedState();
    } else if (event is CallStartPing) {
      yield LoadingStartConnectingState(); //แสดง Loding-Progress... ด้วย
      bool _canStart = await _startConnecting();
      if (!_canStart) {
        add(CallUpdateActiveUser(currentActiveUsers: 'offline'));
      }
    } else if (event is CallStopPing) {
      yield LoadingState(); //สร้าง State-Chang เฉยๆ
      await _stopConnecting();
      yield LoadedState();
    } else if (event is CallUpdateActiveUser) {
      yield ReBuildActiveUserCount_JoypadState(
        currentActiveUsersCount: event.currentActiveUsers,
      );
    } else if (event is CallUpdate_currentIP) {
      yield ReBuild_currentIP(
        currentIP: MyApiWebsocket.getIP(),
      );
      /**
       * NOT need Loading...
       */
    } else if (event is LocalCallApi_sendDataOnly) {
      // call API with Websocket, alert-Err
      _callApiCommand(command: event.command);
    } else if (event is DebugOnlyJoypadEvent) {
      print('event is DebugOnlyJoypadEvent');
    }
  }

  _callApiCommand({@required String command}) async {
    try {
      // call WS send-command.
      _wsSendCommand(command);
    } catch (e) {
      print('Err: _callApiCommand($command)');
      print(e);
    }
  }

  _stopConnecting() async {
    //  call disconnect-to-ws

    try {
      // เคยผ่านมา
      if (this.channel != null) {
        // if (this.channel.closeCode != null) { #ไม่ใช้ เพราะ-cleanup-ด้วย null แล้ว
        // สั่งปิด แต่จะ ReBuild ที่ onDone
        this.channel.sink.close(status.normalClosure);
      } else {
        print('Stop this.channel but it NUll.');
      }
    } catch (e) {
      print(e);
      print('Err: _stopConnecting()!!');
      add(CallUpdateIsConnecting(isConnecting: false));
    }
  }

  Future<bool> _startConnecting() async {
    // start-WS

    try {
      // เคยผ่านมา
      if (this.channel != null) {
        // ปิดการเชื่อมต่อแล้ว
        if (this.channel.closeCode != null) {
          await _wsListenner();
          return true;
        }
        // else กำลังเชื่อมอยู่
      } else {
        // ยังไม่เคย
        await _wsListenner();
        return true;
      }
    } catch (e) {
      print('Err: _startConnecting()');

      print(e);
    }
    return false;
  }

  _wsListenner() async {
    this.channel = IOWebSocketChannel.connect(MyApiWebsocket.getIP());
    add(CallUpdateIsConnecting(isConnecting: true));
    this.channel.stream.listen(
      (message) {
        print('message: $message');
        // Maybe: wrap with try

        // Convert Str to JSON
        final res = convert.json.decode(message);

        switch (res['type']) {
          case 'users':
            // reBuild activeUsersCount
            final String _local_currentActiveUsers = res['count'].toString();
            add(CallUpdateActiveUser(
                currentActiveUsers: _local_currentActiveUsers));
            break;
          case 'connection-id':
            this._currentConnection_ID = res['id'].toString();
            break;
          case 'state':
            if (this._currentConnection_ID == null) {
              // รอให้ได้ ID มาเปรียบเทียบก่อน
              return;
            }
            // Alert has Update state-from-server(only not match id)
            if (this._currentConnection_ID != res['by']) {
              String _local_message = '';

              if ('first-time' != res['by']) {
                // แสดงแค่ ข้อความนี้
                _local_message = 'มีการสั่งงาน Motor จาก devices อื่นๆ';
              } else {
                // _local_message += #คือ ต่อจาก 'มีคนออก, '
                _local_message =
                    _local_message + 'มีการสั่งงาน Motor จาก devices อื่นๆ';
                globalBloc.add(CallShowWarningToUI(message: _local_message));
              }
            }
            // TODO: (cancelled)update state to UI-animetion
            break;
          case 'err':
            //show Err to UI
            globalBloc.add(CallShowErrorToUI(message: res['message']));
            break;
          default:
            print('unsupported event!!');
        }
      },
      onDone: () {
        this._currentConnection_ID = null;
        add(CallUpdateIsConnecting(isConnecting: false));
      },
      onError: (err) {
        add(CallUpdateIsConnecting(isConnecting: false));

        print('onError: $err.');
        globalBloc.add(CallShowErrorToUI(message: err.message));
      },
      cancelOnError: true,
    );
  }

  _wsSendCommand(String command) async {
    final messageJson = {
      'action': 'motor-control',
      'command': command,
    };
    final messageStr = convert.json.encode(messageJson);
    this.channel.sink.add(messageStr);
    print('message: $messageStr');
  }

  // end-class
}
