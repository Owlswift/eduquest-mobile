import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../services/notifications_service.dart';

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  return NotificationsService().getNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  return NotificationsService().getUnreadCount();
});
