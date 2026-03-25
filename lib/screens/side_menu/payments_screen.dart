import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const payments = [
      ('March 03, 2026', '11:00 AM', '₹1,500.00'),
      ('August 13, 2025', '11:00 AM', '₹1,100.00'),
      ('March 03, 2025', '11:00 AM', '₹950.00'),
    ];

    return SideMenuScaffold(
      title: 'List of Payments',
      child: ListView.separated(
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = payments[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6E0D8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.$1}   •   ${item.$2}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
                Text(
                  item.$3,
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
