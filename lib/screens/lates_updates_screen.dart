import 'package:education/screens/side_menu/side_menu_common.dart'
    show SideMenuScaffold;
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class LatestUpdatesScreen extends StatelessWidget {
  const LatestUpdatesScreen({super.key, this.activeTab = false});

  final bool activeTab;

  @override
  Widget build(BuildContext context) {
    const updates = [
      (
        'United Arab Emirates University',
        'United Arab Emirates University proudly marks its graduation ceremony and new research milestones.',
      ),
      (
        'King Saud University',
        'King Saud University organizes its annual research conference with international academic partners.',
      ),
      (
        'Qatar University',
        'Qatar University announces the launch of new academic programs for the upcoming semester.',
      ),
    ];

    return SideMenuScaffold(
      title: 'Lates Updates',
      showBackButton: activeTab,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Recent Updates',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),

          /// ✅ FIXED LIST
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: updates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = updates[index];

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
