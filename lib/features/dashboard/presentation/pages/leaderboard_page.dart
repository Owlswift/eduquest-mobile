import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../controllers/leaderboard_provider.dart';
import '../../models/leaderboard.dart';

/// All-time student ranking by total XP. Backed by GET /users/leaderboard.
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leaderboardProvider);

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
      body: async.when(
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
                  onPressed: () => ref.invalidate(leaderboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) => _LeaderboardBody(data: data),
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  final LeaderboardData data;
  const _LeaderboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final me = data.me;
    final showPinnedMe = me != null && !data.top.any((e) => e.isMe);

    if (data.top.isEmpty) {
      return Center(
        child: Text(
          'No rankings yet.',
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
