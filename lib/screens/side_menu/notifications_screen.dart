import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../services/application_api_service.dart';
import '../../services/notification_sync_service.dart';
import 'side_menu_common.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final ApplicationApiService _api = ApplicationApiService();

  bool _loading = true;

  List<Map<String, dynamic>> _items = [];

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _load();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  String _getGroupTitle(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();

      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);

      final yesterday = today.subtract(
        const Duration(days: 1),
      );

      final itemDate = DateTime(
        date.year,
        date.month,
        date.day,
      );

      if (itemDate == today) {
        return 'Today';
      } else if (itemDate == yesterday) {
        return 'Yesterday';
      } else {
        return DateFormat('dd MMM yyyy').format(date);
      }
    } catch (e) {
      return 'Others';
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupNotifications() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in _items) {
      final group = _getGroupTitle(
        item['createdAt'] ?? '',
      );

      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }

      grouped[group]!.add(item);
    }

    return grouped;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

    final data = await _api.fetchStudentOverview(
      studentUserId: studentUserId,
    );

    final notifications = data['notifications'];

    if (!mounted) return;

    setState(() {
      _items = (notifications is List)
          ? notifications.map<Map<String, dynamic>>((item) {
              return {
                'id': item['id'] ?? '',
                'title': item['title'] ?? '-',
                'message': item['message'] ?? '',
                'createdAt': item['createdAt'] ?? '',
                'isRead': item['isRead'] == true,
              };
            }).toList()
          : [];

      _items.sort((a, b) {
        final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();

        final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();

        return bDate.compareTo(aDate);
      });

      final unread = _items.where((item) => item['isRead'] != true).length;

      NotificationSyncService.instance.updateUnreadCount(unread);

      _loading = false;
    });
  }

  Future<void> _markAsRead(int index) async {
    final item = _items[index];

    if (item['isRead'] == true) return;

    final prefs = await SharedPreferences.getInstance();

    final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

    final id = (item['id'] ?? '').toString();

    if (id.isEmpty || studentUserId.isEmpty) return;

    await _api.markStudentNotificationAsRead(
      notificationId: id,
      studentUserId: studentUserId,
    );

    if (!mounted) return;

    setState(() {
      _items[index]['isRead'] = true;
    });

    final unread = _items.where((entry) => entry['isRead'] != true).length;

    NotificationSyncService.instance.updateUnreadCount(unread);
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupNotifications();

    return SideMenuScaffold(
      title: context.l10n.text('notifications'),
      child: _loading
          ? _buildShimmerList()
          : RefreshIndicator(
              onRefresh: _refresh,
              child: _items.isEmpty
                  ? ListView(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE6E6E6),
                            ),
                          ),
                          child: const Text(
                            'No Notifications Found',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF616161),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    )
                  : ListView(
                      children: groupedItems.entries.map((entry) {
                        final groupTitle = entry.key;
                        final groupItems = entry.value;

                        return NotificationSection(
                          title: groupTitle,
                          items: groupItems,
                          formatDate: _formatDate,
                          formatTime: _formatTime,
                          onTap: (item) {
                            final index = _items.indexOf(item);

                            if (index != -1) {
                              _markAsRead(index);
                            }
                          },
                        );
                      }).toList(),
                    ),
            ),
    );
  }

  Widget _buildShimmerList() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 16,
                    child: Column(
                      children: [
                        _shimmerCircle(),
                        Container(
                          width: 1,
                          height: 90,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _shimmerCard(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _shimmerCircle() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(
            -1 + (_shimmerController.value * 2),
            0,
          ),
          end: Alignment(
            1 + (_shimmerController.value * 2),
            0,
          ),
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerLine(width: double.infinity),
          const SizedBox(height: 10),
          _shimmerLine(width: 220),
          const SizedBox(height: 6),
          _shimmerLine(width: 180),
          const SizedBox(height: 14),
          Row(
            children: [
              _shimmerLine(width: 70),
              const Spacer(),
              _shimmerLine(width: 90),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine({
    required double width,
    double height = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment(
            -1 + (_shimmerController.value * 2),
            0,
          ),
          end: Alignment(
            1 + (_shimmerController.value * 2),
            0,
          ),
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
      ),
    );
  }
}

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
    required this.title,
    required this.items,
    required this.formatDate,
    required this.formatTime,
    required this.onTap,
  });

  final String title;

  final List<Map<String, dynamic>> items;

  final String Function(String) formatDate;

  final String Function(String) formatTime;

  final Function(Map<String, dynamic>) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Column(
            children: List.generate(
              items.length,
              (index) {
                final item = items[index];

                return IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 16,
                          child: Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item['isRead'] == true
                                      ? Colors.grey
                                      : AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 1,
                                  margin: const EdgeInsets.only(
                                    top: 4,
                                  ),
                                  color: const Color(
                                    0xFFCAC2B8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(item),
                            child: NotificationCard(
                              title: item['title'] ?? '',
                              description: item['message'] ?? '',
                              time: formatTime(
                                item['createdAt'] ?? '',
                              ),
                              date: formatDate(
                                item['createdAt'] ?? '',
                              ),
                              isRead: item['isRead'] == true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.isRead,
  });

  final String title;

  final String description;

  final String time;

  final String date;

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFD7D4D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description.isEmpty
                ? context.l10n.text(
                    'notificationDescription',
                  )
                : description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                date,
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
