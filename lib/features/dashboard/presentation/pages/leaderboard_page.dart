import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../controllers/leaderboard_provider.dart';
import '../../models/leaderboard.dart';

/// Student ranking by XP - all-time total, or earned within the last
/// 7/30 days. Backed by GET /users/leaderboard?period=.
class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  static const _periods = [('all', 'All-time'), ('weekly', 'This week'), ('monthly', 'This month')];
  String _period = 'all';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(leaderboardForPeriodProvider(_period));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: _periods
                  .map((p) => Expanded(child: _PeriodChip(
                        label: p.$2,
                        selected: _period == p.$1,
                        onTap: () => setState(() => _period = p.$1),
                      )))
                  .toList(),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Couldn't load the leaderboard.",
                        style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(leaderboardForPeriodProvider(_period)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) => _LeaderboardBody(data: data, period: _period),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: selected ? null : AppShadows.card,
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: selected ? Colors.white : AppColors.subtitle,
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  final LeaderboardData data;
  final String period;
  const _LeaderboardBody({required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    final me = data.me;
    final showPinnedMe = me != null && !data.top.any((e) => e.isMe);

    if (data.top.isEmpty) {
      return Center(
        child: Text(
          period == 'all'
              ? 'No rankings yet.'
              : "No one has earned XP in this window yet - be the first!",
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.fromLTRB(20, 20, 20, showPinnedMe ? 110 : 24),
          itemCount: data.top.length,
          itemBuilder: (_, i) => _LeaderboardTile(entry: data.top[i]),
        ),
        if (showPinnedMe)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _rankBadge('#${me.rank}', Colors.white.withValues(alpha: 0.2),
                      Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    '${me.xp} XP',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static Widget _rankBadge(String text, Color bg, Color fg) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderboardTile({required this.entry});

  static const _rankColors = {
    1: Color(0xFFFBBF24),
    2: Color(0xFF94A3B8),
    3: Color(0xFFCD7C2F),
  };

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: entry.isMe ? const Color(0xFFEDF5FF) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.card,
        border: entry.isMe
            ? Border.all(color: const Color(0xFFCFE1FF), width: 1.5)
            : isTop3
                ? Border.all(
                    color: _rankColors[entry.rank]!.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isTop3
                ? Icon(Icons.emoji_events_rounded,
                    color: _rankColors[entry.rank], size: 24)
                : Text(
                    '#${entry.rank}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.subtitle,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.isMe ? '${entry.name} (You)' : entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontWeight: entry.isMe ? FontWeight.w800 : FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: entry.isMe ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
