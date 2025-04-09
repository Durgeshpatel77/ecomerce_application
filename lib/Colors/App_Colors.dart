import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorConst {
  static Color babyBlue = Color(0xff8d44d7);
  static Color feijoa = Color(0xff40b5c2);
  static Color white = Colors.white;


  static LinearGradient verticalGradient = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [feijoa, babyBlue]);

  static LinearGradient horizontalGradient= LinearGradient(
      begin:Alignment.bottomLeft,
      end: Alignment.bottomRight,
      colors: [feijoa,babyBlue]
  );
}
