import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/responsive.dart';
import '../../../rewards/controllers/rewards_provider.dart';
import '../../../rewards/models/reward.dart';
import '../../../rewards/services/rewards_service.dart';
import '../../controllers/refresh.dart';

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hPad = context.isTablet ? 40.0 : 20.0;
    final async = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(rewardsProvider),
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
                          "Couldn't load rewards.",
                          style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                        ),
                        const Gap(12),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(rewardsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            data: (catalog) => _RewardsBody(catalog: catalog, hPad: hPad),
          ),
        ),
      ),
    );
  }
}

class _RewardsBody extends StatelessWidget {
  final RewardsCatalog catalog;
  final double hPad;
  const _RewardsBody({required this.catalog, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
            child: Text('Rewards', style: AppTextStyles.title.copyWith(fontSize: context.rs(24))),
          ),
        ),
        const SliverToBoxAdapter(child: Gap(16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: _RewardsProgressCard(coins: catalog.coins, rewards: catalog.rewards),
          ),
        ),
        const SliverToBoxAdapter(child: Gap(24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Text('Redeem Coins', style: AppTextStyles.title.copyWith(fontSize: context.rs(18))),
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
              (context, index) => _RewardCard(reward: catalog.rewards[index]),
              childCount: catalog.rewards.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardsProgressCard extends StatelessWidget {
  final int coins;
  final List<Reward> rewards;

  const _RewardsProgressCard({required this.coins, required this.rewards});

  @override
  Widget build(BuildContext context) {
    // The next thing worth saving toward: the cheapest reward not yet
    // affordable. If everything is already affordable, there's nothing
    // left to count down to.
    final locked = rewards.where((r) => !r.canAfford).toList()
      ..sort((a, b) => a.coinCost.compareTo(b.coinCost));
    final next = locked.isEmpty ? null : locked.first;

    if (next == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffECFDF5),
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: context.rs(22))),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'You have $coins coins - enough for any reward!',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16A34A),
                  fontSize: context.rs(14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final progress = (coins / next.coinCost).clamp(0.0, 1.0);
    final remaining = (next.coinCost - coins).clamp(0, next.coinCost);

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
              Expanded(
                child: Text(
                  'Next reward: ${next.title}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff16A34A),
                    fontSize: context.rs(14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                '$coins / ${next.coinCost} Coins',
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

class _RewardCard extends ConsumerStatefulWidget {
  final Reward reward;
  const _RewardCard({required this.reward});

  @override
  ConsumerState<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends ConsumerState<_RewardCard> {
  bool _redeeming = false;

  Future<void> _onTap() async {
    final reward = widget.reward;
    if (!reward.canAfford || _redeeming) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Redeem ${reward.title}?'),
        content: Text('This will use ${reward.coinCost} coins for ${reward.subtitle}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _redeeming = true);
    try {
      await RewardsService().redeem(reward.id);
      ref.invalidate(rewardsProvider);
      invalidateUserStats(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${reward.title} redeemed!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't redeem that right now - try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reward = widget.reward;
    final visuals = RewardVisuals.forId(reward.id);
    final locked = !reward.canAfford;

    return Opacity(
      opacity: locked ? 0.5 : 1,
      child: InkWell(
        onTap: locked ? null : _onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: context.isTablet ? 48 : 40,
                    height: context.isTablet ? 48 : 40,
                    decoration: BoxDecoration(
                      color: visuals.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _redeeming
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(visuals.icon, color: visuals.color, size: context.isTablet ? 26 : 22),
                  ),
                  if (locked)
                    const Icon(Icons.lock_rounded, color: AppColors.subtitle, size: 16),
                ],
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
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFFBBF24), size: 14),
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
        ),
      ),
    );
  }
}
