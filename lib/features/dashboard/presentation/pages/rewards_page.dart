import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/mock_data.dart';
import '../../models/dashboard_models.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  static const _coins = 50;
  static const _nextRewardCost = 100;

  @override
  Widget build(BuildContext context) {
    final hPad = context.isTablet ? 40.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                child: Text(
                  'Rewards',
                  style:
                      AppTextStyles.title.copyWith(fontSize: context.rs(24)),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: _RewardsProgressCard(
                  coins: _coins,
                  nextRewardCost: _nextRewardCost,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Text(
                  'Redeem Coins',
                  style:
                      AppTextStyles.title.copyWith(fontSize: context.rs(18)),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(12)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 120),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.isTablet ? 4 : 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _RewardCard(reward: mockRewards[index]),
                  childCount: mockRewards.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsProgressCard extends StatelessWidget {
  final int coins;
  final int nextRewardCost;

  const _RewardsProgressCard({
    required this.coins,
    required this.nextRewardCost,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (coins / nextRewardCost).clamp(0.0, 1.0);
    final remaining = (nextRewardCost - coins).clamp(0, nextRewardCost);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffECFDF5),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🎁', style: TextStyle(fontSize: context.rs(20))),
              const SizedBox(width: 8),
              Text(
                'Next reward: Airtime',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16A34A),
                  fontSize: context.rs(14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.isTablet ? 14 : 12,
              backgroundColor: Colors.white,
              color: const Color(0xff16A34A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$coins / $nextRewardCost Coins',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: context.rs(14),
                ),
              ),
              Text(
                '$remaining coins away',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xff16A34A),
                  fontWeight: FontWeight.w600,
                  fontSize: context.rs(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewardModel reward;

  const _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.isTablet ? 48 : 40,
            height: context.isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: reward.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(reward.icon,
                color: reward.color, size: context.isTablet ? 26 : 22),
          ),
          const Spacer(),
          Text(
            reward.title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              fontSize: context.rs(14),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            reward.subtitle,
            style: AppTextStyles.body.copyWith(fontSize: context.rs(12)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: Color(0xFFFBBF24), size: 14),
              const SizedBox(width: 4),
              Text(
                '${reward.coinCost}',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: context.rs(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
