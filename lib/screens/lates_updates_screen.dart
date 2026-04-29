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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
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
        ...updates.map(
              (item) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFDAD6D1))),
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
                const SizedBox(height: 2),
                Text(
                  item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
