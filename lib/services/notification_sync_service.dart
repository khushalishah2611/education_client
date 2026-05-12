import 'package:flutter/foundation.dart';

class NotificationSyncService {
  NotificationSyncService._();

  static final NotificationSyncService instance = NotificationSyncService._();

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  void updateUnreadCount(int count) {
    if (unreadCount.value != count) {
      unreadCount.value = count;
    }
  }
}
