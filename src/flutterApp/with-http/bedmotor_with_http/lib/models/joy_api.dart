import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class JoyApiModel extends Equatable {
  final String motorNumber;
  final String text;
  final String arrow;

  JoyApiModel({
    @required this.motorNumber,
    @required this.text,
    @required this.arrow,
  });

  @override
  List<Object> get props => [
        motorNumber,
        text,
        arrow,
      ];

  // --for debug
  @override
  String toString() {
    return json.encode({
      'motorNumber': this.motorNumber,
      'text': this.text,
      'arrow': this.arrow,
    });
  }
}
