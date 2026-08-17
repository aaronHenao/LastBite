import 'package:flutter/material.dart';

class Responsive {
  static const double _mobileMax = 600;
  static const double _tabletMax = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileMax &&
      MediaQuery.of(context).size.width < _tabletMax;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletMax;

  static bool isTabletOrWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileMax;

  //ancho max contenido web/tablet
  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _tabletMax) return 1100;
    if (width >= _mobileMax) return 700;
    return width;
  }

  //segun la pantalla
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _tabletMax) return width * 0.15;
    if (width >= _mobileMax) return 40;
    return 20;
  }

  static int gridColumns(BuildContext context) {
    if (isWeb(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }
}