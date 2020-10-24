import 'package:bedmotor_with_http/models/models.dart';

class JoyMotorName {
  static final JoyApiModel m1IsRight = JoyApiModel(
    motorNumber: '1',
    text: 'ด้านขวา',
    arrow: 'r',
  );
  static final JoyApiModel m2IsLeft = JoyApiModel(
    motorNumber: '2',
    text: 'ด้านซ้าย',
    arrow: 'l',
  );
}

class JoyActions {
  static final String up = 'u';
  static final String down = 'd';
  static final String stop = '0';
  // static final String up = 'a';
  // static final String down = 'b';
  // static final String stop = '0';
}
