import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../controllers/rewards_provider.dart';
import '../../models/reward.dart';

/// Fulfillment (actually sending the airtime/data/etc.) is a manually
/// worked queue, not automated - this shows the real status honestly
/// instead of implying a redemption completes instantly.
class RewardsHistoryPage extends ConsumerWidget {
  const RewardsHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rewardsHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          'Redemption History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(rewardsHistoryProvider),
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
                        "Couldn't load your redemption history.",
                        style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                      ),
                      const Gap(12),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(rewardsHistoryProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (redemptions) {
            if (redemptions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 120),
                    child: Center(
                      child: Text(
                        "You haven't redeemed anything yet.",
                        style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: redemptions.length,
              itemBuilder: (_, i) => _RedemptionTile(redemption: redemptions[i]),
            );
          },
        ),
      ),
    );
  }
}

class _RedemptionTile extends StatelessWidget {
  final RewardRedemption redemption;
  const _RedemptionTile({required this.redemption});

  ({String label, Color color, IconData icon}) get _statusInfo {
    switch (redemption.status) {
      case 'FULFILLED':
        return (label: 'Delivered', color: AppColors.success, icon: Icons.check_circle_rounded);
      case 'REJECTED':
        return (label: 'Refunded', color: AppColors.danger, icon: Icons.cancel_rounded);
      default:
        return (label: 'Pending', color: AppColors.warning, icon: Icons.hourglass_top_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo;
    final visuals = RewardVisuals.forId(redemption.rewardId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: visuals.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(visuals.icon, color: visuals.color, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(redemption.title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                const Gap(3),
                Text(
                  '${redemption.coinCost} coins · ${_formatDate(redemption.redeemedAt)}',
                  style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status.icon, color: status.color, size: 14),
              const Gap(4),
              Text(
                status.label,
                style: AppTextStyles.body.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}
