import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../controllers/challenges_provider.dart';
import '../../models/challenge_models.dart';
import 'challenge_detail_page.dart';

/// The "Challenges" tab inside the Arena screen - every 1v1 challenge I'm
/// part of, sent or received, newest first.
class ChallengesTab extends ConsumerWidget {
  const ChallengesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(challengesListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(challengesListProvider),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 120),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Couldn't load challenges.", style: AppTextStyles.body.copyWith(color: AppColors.subtitle)),
                    const Gap(12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(challengesListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        data: (challenges) {
          if (challenges.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sports_martial_arts_rounded,
                            size: 56, color: AppColors.subtitle.withValues(alpha: 0.4)),
                        const Gap(16),
                        Text(
                          'No challenges yet - tap + to\nchallenge a classmate.',
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: challenges.length,
            itemBuilder: (_, i) => _ChallengeTile(challenge: challenges[i]),
          );
        },
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  final ChallengeSummary challenge;
  const _ChallengeTile({required this.challenge});

  (String, Color) get _statusLabelAndColor {
    switch (challenge.status) {
      case ChallengeStatus.pending:
        return (challenge.role == ChallengeRole.opponent ? 'Respond' : 'Waiting', AppColors.warning);
      case ChallengeStatus.active:
        return ('Active', AppColors.primary);
      case ChallengeStatus.completed:
        return ('Completed', AppColors.success);
      case ChallengeStatus.declined:
        return ('Declined', AppColors.danger);
      case ChallengeStatus.unknown:
        return ('', AppColors.subtitle);
    }
  }

  String get _scoreLabel {
    if (challenge.myScore == null && challenge.theirScore == null) return '';
    return '${challenge.myScore ?? '-'} : ${challenge.theirScore ?? '-'}';
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusLabelAndColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChallengeDetailPage(challengeId: challenge.id)),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.sports_martial_arts_rounded, color: color, size: 22),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${challenge.subjectName} vs ${challenge.opponent.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const Gap(3),
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
              ),
              if (_scoreLabel.isNotEmpty)
                Text(_scoreLabel, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15))
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
