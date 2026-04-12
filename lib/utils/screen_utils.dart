import 'package:flutter/material.dart';

class ScreenUtils {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double wp(BuildContext context, double percentage) {
    return width(context) * percentage / 100;
  }

  static double hp(BuildContext context, double percentage) {
    return height(context) * percentage / 100;
  }

  static double sp(BuildContext context, double size) {
    return size * width(context) / 375;
  }
}
