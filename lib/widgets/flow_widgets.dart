import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'common_widgets.dart';

class TopRoundedHeader extends StatelessWidget {
  const TopRoundedHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack ?? () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(color: Color(0xFFF6F6F6), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            ],
          ),
        ],
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
  const BottomTabBarCard({super.key, this.activeIndex = 0, this.onTap});

  final int activeIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.account_balance_outlined, 'University'),
      (Icons.school_outlined, 'College'),
      (Icons.corporate_fare_outlined, 'Private School'),
      (Icons.location_on_outlined, 'Location'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
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
              final isActive = index == activeIndex;
              return Expanded(
                child: InkWell(
                  onTap: onTap == null ? null : () => onTap!(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFFF9F2E) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.$1, color: isActive ? Colors.white : AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(item.$2, style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Container(width: 130, height: 4, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100))),
        ],
      ),
    );
  }
}
