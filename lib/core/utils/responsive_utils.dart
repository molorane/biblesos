import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static int getCrossAxisCount(BuildContext context, {int phone = 2, int tablet = 4, int desktop = 6}) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1024) return desktop;
    if (width >= 600) return tablet;
    return phone;
  }

  static double getHorizontalPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1024) return width * 0.2;
    if (width >= 600) return width * 0.1;
    return 16.0;
  }
}
