import 'package:flutter/material.dart';

class ColorVals{
  static final ColorVals _instance = ColorVals.init();

  ColorVals.init() {}
  factory ColorVals() {
    return _instance;
  }

  var PRIMARY_SKYBLUE = Color(0xff1DA1F2);
  var PRIMARY_GREY = Color(0xffE9E9E9);

  var BACKGROUND_DELETE_RED = Color(0xffF34642);

  var TXT_WHITE = Colors.white;
  var TXT_BLUE = Color(0xff1DA1F2);
  var TXT_BLACK = Colors.black;
  var TXT_DULL = Color(0xff949C9E);

  var BORDER_GREY = Colors.grey;
}