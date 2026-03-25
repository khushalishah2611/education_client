import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const todayItems = [
      NotificationItemData('Documents approved successfully'),
      NotificationItemData('Reminder: Application deadline is approaching'),
    ];

    const yesterdayItems = [
      NotificationItemData('Documents approved successfully'),
      NotificationItemData('Reminder: Application deadline is approaching'),
      NotificationItemData('Reminder: Application deadline is approaching'),
    ];

    return SideMenuScaffold(
      title: 'Notifications',
      child: ListView(
        children: const [
          NotificationSection(title: 'Today', items: todayItems),
          SizedBox(height: 10),
          NotificationSection(title: 'Yesterday', items: yesterdayItems),
        ],
      ),
    );
  }
}

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key, required this.title, required this.items});

  final String title;
  final List<NotificationItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 10),
        ...List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 16,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 1,
                          height: 60,
                          margin: const EdgeInsets.only(top: 4),
                          color: const Color(0xFFCAC2B8),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: NotificationCard(title: item.title)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD7D4D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Short description explaining the notification details\nin a compact way...',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text('10:00 PM', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Spacer(),
              Text('03 Mar 2026', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationItemData {
  const NotificationItemData(this.title);

  final String title;
}
