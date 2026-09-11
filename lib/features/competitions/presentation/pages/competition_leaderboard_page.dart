import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../controllers/competitions_provider.dart';
import '../../models/competition.dart';

/// Ranking within a single competition, by XP earned since joining.
class CompetitionLeaderboardPage extends ConsumerWidget {
  final String competitionId;
  final String competitionTitle;

  const CompetitionLeaderboardPage({
    super.key,
    required this.competitionId,
    required this.competitionTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(competitionLeaderboardProvider(competitionId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: Text(
          competitionTitle,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
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
                  "Couldn't load this leaderboard.",
                  style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(competitionLeaderboardProvider(competitionId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          if (data.top.isEmpty) {
            return Center(
              child: Text(
                'No one has joined yet - be the first!',
                style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.top.length,
            itemBuilder: (_, i) => _EntryTile(entry: data.top[i]),
          );
        },
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final CompetitionLeaderboardEntry entry;
  const _EntryTile({required this.entry});

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
            '+${entry.xpEarned} XP',
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
