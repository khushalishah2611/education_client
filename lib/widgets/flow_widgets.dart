import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/responsive_helper.dart';

void showAddressBottomSheet({
  required BuildContext context,
  required String? address,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final String value =
          address?.trim().isNotEmpty == true ? address!.trim() : '-';
      final double screenHeight = MediaQuery.of(sheetContext).size.height;
      final double sheetHeight = (screenHeight * 0.3).clamp(210.0, 320.0);
      return SafeArea(
        child: SizedBox(
          height: sheetHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sheetContext.l10n.text('location'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Text(
                          value,
                          style: const TextStyle(
                            height: 1.4,
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class TopRoundedHeader extends StatelessWidget {
  const TopRoundedHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    final double contentHeight = context.responsiveAppBarContentHeight;
    final double sidePadding = context.responsiveHorizontalPadding;
    final double backButtonSize = context.responsiveAppBarButtonSize;
    final double titleFontSize = context.responsiveAppBarTitleSize;
    final double backIconSize = context.isSmallMobile ? 16 : 18;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(
        top: topInset,
        left: sidePadding,
        right: sidePadding,
        bottom: 8,
      ),
      child: SizedBox(
        height: contentHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: backButtonSize,
                height: backButtonSize,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: backIconSize,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: context.responsiveAppBarTitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(width: backButtonSize),
          ],
        ),
      ),
    );
  }
}

class FlowStepHeader extends StatelessWidget {
  const FlowStepHeader({
    super.key,
    required this.currentStep,
    required this.title,
    this.onBack,
  });

  final int currentStep;
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final labels = [
      context.l10n.text('stepUploadDoc'),
      // context.l10n.text('stepVerify'),
      context.l10n.text('stepPayment'),
      context.l10n.text('stepStatus'),
    ];
    return Column(
      children: [
        TopRoundedHeader(title: title, onBack: onBack),
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.responsiveHorizontalPadding,
            14,
            context.responsiveHorizontalPadding,
            0,
          ),
          child: Row(
            children: List.generate(labels.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: const Color(0xFFD6C7B8),
                  ),
                );
              }
              final stepIndex = index ~/ 2;
              final isActive = stepIndex <= currentStep;
              return Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.accent : const Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: isSmallMobile ? 50 : 58,
                    child: Text(
                      labels[stepIndex],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: isSmallMobile ? 10 : 12),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class BottomTabBarCard extends StatelessWidget {
  const BottomTabBarCard({super.key, this.activeIndex, this.onTap});

  final int? activeIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      ("assets/images/home.svg", context.l10n.text('university')),
      ("assets/images/application.svg", context.l10n.text('TrainingCourse')),
      ("assets/images/documents.svg", context.l10n.text('privateSchool')),
      ("assets/images/updates.svg", context.l10n.text('Lates Updates')),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = activeIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔶 ICON CIRCLE
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFFF9F2E)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            item.$1.toString(),
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                            color: isActive ? Colors.white : AppColors.text,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // 🔤 TEXT
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isActive ? Colors.black : AppColors.textMuted,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 6),

          // ⬛ Bottom Indicator
          Container(
            width: 110,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }
}
