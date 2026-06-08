import 'package:flutter/widgets.dart';

extension ResponsiveHelper on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isSmallMobile => screenWidth <= 360;
  bool get isMediumMobile => screenWidth > 360 && screenWidth <= 420;
  bool get isLargeMobile => screenWidth > 420;

  bool get isShortScreen => screenHeight <= 700;
  bool get isVeryShortScreen => screenHeight <= 640;

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

  /// Toolbar row height only — add [MediaQuery.paddingOf].top for full app bar.
  double get responsiveAppBarContentHeight {
    if (isSmallMobile) return 48;
    if (isMediumMobile) return 52;
    return 56;
  }

  double get responsiveAppBarHeight {
    final double topInset = MediaQuery.paddingOf(this).top;
    return topInset + responsiveAppBarContentHeight + 8;
  }

  double get responsiveUniversityBannerHeight => 260;

  double get responsiveUniversityDetailTopGap {
    if (isSmallMobile) return 48;
    if (isMediumMobile) return 52;
    return 56;
  }

  double get responsiveAppBarTitleSize {
    if (isSmallMobile) return 15;
    if (isMediumMobile) return 16;
    return 18;
  }

  double get responsiveAppBarButtonSize => isSmallMobile ? 32 : 34;

  int get responsiveAppBarTitleMaxLines => isSmallMobile ? 2 : 1;

  double get responsiveHomeToolbarHeight {
    if (isVeryShortScreen || isSmallMobile) return 40;
    if (isMediumMobile) return 42;
    return 44;
  }

  double get responsiveHomeCircleButtonSize {
    if (isVeryShortScreen || isSmallMobile) return 36;
    if (isMediumMobile) return 38;
    return 40;
  }

  double get responsiveHomeToolbarIconSize {
    if (isVeryShortScreen || isSmallMobile) return 22;
    if (isMediumMobile) return 24;
    return 26;
  }

  double get responsiveHomeNotificationIconSize {
    if (isVeryShortScreen || isSmallMobile) return 22;
    if (isMediumMobile) return 24;
    return 26;
  }

  double get responsiveDiscoverBannerHeight {
    if (isVeryShortScreen) return 110;
    if (isShortScreen || isSmallMobile) return 125;
    if (isMediumMobile) return 135;
    return 150;
  }

  double get responsiveHomeSearchFieldHeight {
    if (isVeryShortScreen) return 38;
    if (isShortScreen || isSmallMobile) return 40;
    return 44;
  }

  double get responsiveHomeSearchFontSize {
    if (isVeryShortScreen || isSmallMobile) return 13;
    return 14;
  }

  double get responsiveHomeSectionSpacing {
    if (isVeryShortScreen) return 6;
    if (isShortScreen || isSmallMobile) return 8;
    if (isMediumMobile) return 10;
    return 12;
  }

  double get responsiveHomeBannerIndicatorGap {
    if (isVeryShortScreen) return 10;
    if (isShortScreen || isSmallMobile) return 14;
    return 20;
  }

  double get responsiveHomeHeaderBottomPadding {
    if (isVeryShortScreen) return 4;
    return 8;
  }

  double get responsiveHomeHeaderContentHeight {
    const double indicatorHeight = 8;
    return responsiveHomeToolbarHeight +
        responsiveHomeSectionSpacing +
        (responsiveHomeSearchFieldHeight * 2) +
        (responsiveHomeSectionSpacing * 2) +
        responsiveDiscoverBannerHeight +
        responsiveHomeBannerIndicatorGap +
        indicatorHeight +
        responsiveHomeHeaderBottomPadding;
  }

  double get responsiveHomeHeaderHeight {
    final double contentHeight = responsiveHomeHeaderContentHeight;
    final double maxHeight = screenHeight * 0.52;
    return contentHeight.clamp(240, maxHeight);
  }
}
