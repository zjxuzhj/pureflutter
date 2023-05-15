import 'package:flutter/material.dart';

class SizeFit {
  static double scaleWidth = 0;
  static double scaleHeight = 0;
  static double screenWidth = 0;
  static double screenHeight = 0;

  //iPhone xs为标准
  static void initialize(BuildContext context, {double standardWidth: 375, double standardHeight: 819}) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    scaleWidth = screenWidth / standardWidth;
    scaleHeight = screenHeight / standardHeight;
  }

  // 按照屏幕高度比例来设置
  static double setScreenW(double size) {
    return SizeFit.scaleWidth * size;
  }

  // 按照屏幕宽度比例来设置
  static double setScreenH(double size) {
    return SizeFit.scaleHeight * size;
  }
}
