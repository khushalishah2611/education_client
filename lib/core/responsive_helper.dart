import 'package:flutter/widgets.dart';

extension ResponsiveHelper on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isSmallMobile => screenWidth <= 360;
  bool get isMediumMobile => screenWidth > 360 && screenWidth <= 420;
  bool get isLargeMobile => screenWidth > 420;

  double get responsiveHorizontalPadding {
    if (isSmallMobile) return 12;
    if (isMediumMobile) return 16;
    return 20;
  }

  int get responsiveGridColumns {
    if (isSmallMobile) return 1;
    if (isMediumMobile) return 2;
    return 2;
  }

  double get responsiveCardRadius => isSmallMobile ? 10 : 14;
}
