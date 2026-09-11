import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../controllers/notifications_provider.dart';
import '../../models/app_notification.dart';
import '../../services/notifications_service.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    void refresh() {
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificationsService().markAllRead();
              refresh();
            },
            child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 120),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Couldn't load notifications.",
                        style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                      ),
                      const Gap(12),
                      OutlinedButton(onPressed: refresh, child: const Text('Retry')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 120),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_none_rounded,
                              size: 48, color: AppColors.subtitle),
                          const Gap(12),
                          Text(
                            'Nothing yet - study, join a competition, or\nredeem a reward to see updates here.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];
                return _NotificationTile(
                  notification: n,
                  onTap: n.read
                      ? null
                      : () async {
                          await NotificationsService().markRead(n.id);
                          refresh();
                        },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  const _NotificationTile({required this.notification, this.onTap});

  IconData get _icon {
    switch (notification.type) {
      case 'reward_redeemed':
        return Icons.card_giftcard_rounded;
      case 'competition_joined':
        return Icons.emoji_events_rounded;
      case 'badge_earned':
        return Icons.military_tech_rounded;
      case 'welcome_bonus':
        return Icons.celebration_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String get _relativeTime {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : const Color(0xFFEDF5FF),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: AppColors.primary, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const Gap(3),
                  Text(
                    notification.body,
                    style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 13),
                  ),
                  const Gap(6),
                  Text(
                    _relativeTime,
                    style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
