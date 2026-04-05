import 'package:flutter/animation.dart';

class AppAnimations {
  const AppAnimations._();

  static const dur50 = Duration(milliseconds: 50);
  static const dur100 = Duration(milliseconds: 100);
  static const dur200 = Duration(milliseconds: 200);
  static const dur250 = Duration(milliseconds: 250);
  static const dur300 = Duration(milliseconds: 300);
  static const dur350 = Duration(milliseconds: 350);
  static const dur400 = Duration(milliseconds: 400);
  static const dur500 = Duration(milliseconds: 500);
  static const dur600 = Duration(milliseconds: 600);
  static const dur900 = Duration(milliseconds: 900);
  static const dur1200 = Duration(milliseconds: 1200);

  static const smoothOut = Cubic(0.23, 1.00, 0.32, 1.00);
  static const springSnappy = Cubic(0.34, 1.56, 0.64, 1.00);
  static const gentleFade = Cubic(0.40, 0.00, 0.20, 1.00);
  static const pressIn = Cubic(0.40, 0.00, 1.00, 1.00);
  static const easeOutBack = Cubic(0.34, 1.56, 0.64, 1.00);
}
