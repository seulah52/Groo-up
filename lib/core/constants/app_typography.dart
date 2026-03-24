import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamily = 'PretendardVariable';
  static const h1 = TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w700);
  static const h2 = TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w600);
  static const h3 = TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400);
  static const caption = TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w400);
}
