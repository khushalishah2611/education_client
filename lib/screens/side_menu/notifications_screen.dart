import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayItems = [
      NotificationItemData(context.l10n.text('documentsApprovedSuccessfully')),
      NotificationItemData(context.l10n.text('applicationDeadlineReminder')),
    ];

    final yesterdayItems = [
      NotificationItemData(context.l10n.text('documentsApprovedSuccessfully')),
      NotificationItemData(context.l10n.text('applicationDeadlineReminder')),
      NotificationItemData(context.l10n.text('applicationDeadlineReminder')),
    ];

    return SideMenuScaffold(
      title: context.l10n.text('notifications'),
      child: ListView(
        children: [
          NotificationSection(
            title: context.l10n.text('today'),
            items: todayItems,
          ),
          const SizedBox(height: 10),
          NotificationSection(
            title: context.l10n.text('yesterday'),
            items: yesterdayItems,
          ),
        ],
      ),
    );
  }
}

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<NotificationItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
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
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.text('notificationDescription'),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                context.l10n.text('notificationTime'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.text('notificationDate'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
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
