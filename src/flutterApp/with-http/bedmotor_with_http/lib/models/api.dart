import 'package:bedmotor_with_http/configs/configs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';

class MyApiDio {
  static String _ipServer = ConfigsEnv.apiDomain;

  static SharedPreferences _prefs;

  static saveP() async {
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
    if (lastIP != null) {
      _ipServer = lastIP;
      print('SharedPreferences(...) -> lastIP : $_ipServer');
    }
    return true;
  }

  static String getIP() {
    return _ipServer;
  }

  static stop() async {
    final String url = _ipServer + ConfigsApiPath.pathStop;

    var dio = Dio();
    try {
      Response response = await dio.get(url,
          queryParameters: {"time": new DateTime.now().millisecondsSinceEpoch});
    } catch (e) {
      // TODO: show snackBar
      return false;
    }
    return true;
  }

  static Future<bool> motorApi(String path) async {
    final String url = _ipServer + path;

    try {
      final dio = Dio();
      Response response = await dio.get(url,
          queryParameters: {"time": new DateTime.now().millisecondsSinceEpoch});

      if (response.data['dataStatus'] == 'success') {
        return true;
      }
    } catch (e) {
      // TODO: show onetime-snackBar
      return false;
    }

    return false;
  }
}
