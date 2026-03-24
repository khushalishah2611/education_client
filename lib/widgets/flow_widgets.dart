import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';


class TopRoundedHeader extends StatelessWidget {
  const TopRoundedHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// BACK BUTTON (LEFT)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: InkWell(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            /// TITLE (PERFECT CENTER)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlowStepHeader extends StatelessWidget {
  const FlowStepHeader({super.key, required this.currentStep, required this.title});

  final int currentStep;
  final String title;

  @override
  Widget build(BuildContext context) {
    const labels = ['Upload Doc.', 'Verify', 'Payment', 'Status'];
    return Column(
      children: [
        TopRoundedHeader(title: title),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
                      color: isActive ? AppColors.accent : const Color(0xFFF0F0F0),
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
                    width: 58,
                    child: Text(labels[stepIndex], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
      (Icons.account_balance_outlined, context.l10n.text('university')),
      (Icons.school_outlined, context.l10n.text('college')),
      (Icons.corporate_fare_outlined, context.l10n.text('privateSchool')),
      (Icons.location_on_outlined, context.l10n.text('location')),
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
              final isActive = activeIndex != null && index == activeIndex;
              return Expanded(
                child: InkWell(
                  onTap: onTap == null ? null : () => onTap!(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFFF9F2E) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.$1, color: isActive ? Colors.white : AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Container(width: 110, height: 3, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100))),
        ],
      ),
    );
  }
}
