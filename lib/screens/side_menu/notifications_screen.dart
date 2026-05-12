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

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = const ApplicationApiService();

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final formattedDate = DateFormat('dd-MM-yyyy').format(date);
      final weekday = DateFormat('EEEE').format(date);
      return '$formattedDate $weekday';
    } catch (e) {
      return dateStr;
    }
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

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE6E6E6),
          ),
          color: Colors.white,
        ),
        child: Text(
          context.l10n.text('No notifications available'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF616161),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('notifications'),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _emptyState(context),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: _items.map((e) {
                          return NotificationCard(
                            title: e['title'] ?? '-',
                            description: e['message'] ?? '',
                            date: _formatDate(e['createdAt'] ?? ''),
                            isRead: e['isRead'] == true,
                            onTap: () => _markAsRead(_items.indexOf(e)),
                          );
                        }).toList(),
                      ),
              ),
            ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.isRead,
    required this.onTap,
  });

  final String title;
  final String description;
  final String date;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFFFF3E6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isRead ? const Color(0xFFD7D4D0) : AppColors.accent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
