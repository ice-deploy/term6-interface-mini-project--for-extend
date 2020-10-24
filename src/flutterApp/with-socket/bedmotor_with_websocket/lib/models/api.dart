import 'package:shared_preferences/shared_preferences.dart';

import '../configs/configs.dart';

class MyApiWebsocket {
  static String _ipServer = ConfigsEnv.apiDomain;

  static SharedPreferences _prefs;

  static saveP() async {
    // NOTE: save to SharedPreferences
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs.setString('lastIP', _ipServer);
    return true;
  }

  static setIP(String ip) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _ipServer = ip;
    // save lastIP to Shared-preference
    await _prefs.setString('lastIP', _ipServer);

    return true;
  }

  static initIP() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    final lastIP = _prefs.getString('lastIP');
    print('lastIP.runtimeType: ${lastIP.runtimeType}');
    if (lastIP != null) {
      _ipServer = lastIP;
      print('SharedPreferences(_prefs) -> lastIP : $_ipServer');
    }
    return true;
  }

  static String getIP() {
    return _ipServer;
  }
}
