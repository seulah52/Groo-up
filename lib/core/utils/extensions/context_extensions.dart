import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData   get theme       => Theme.of(this);
  TextTheme   get textTheme   => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  double get screenWidth  => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool   get isDark       => Theme.of(this).brightness == Brightness.dark;
}
