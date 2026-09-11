import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import '../../controllers/notifications_provider.dart';
import '../pages/notifications_page.dart';

/// The header bell icon - shared by Home and Learn tabs. Shows a real
/// unread-count dot (from GET /notifications/unread-count) and opens the
/// notification list on tap, refreshing the count on return.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        ref.invalidate(unreadNotificationCountProvider);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: context.isTablet ? 56 : 48,
            height: context.isTablet ? 56 : 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 16, color: Colors.black12)],
            ),
            child: Icon(Icons.notifications_none_rounded, size: context.isTablet ? 28 : 24),
          ),
          if (unread > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4338),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
