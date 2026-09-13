import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../quiz/models/quiz_models.dart';
import '../../../quiz/services/quiz_service.dart';
import '../../controllers/challenges_provider.dart';
import '../../models/challenge_models.dart';
import '../../services/challenges_service.dart';
import 'challenge_play_page.dart';
import 'challenge_results_page.dart';

/// The single screen for viewing/acting on one Challenge, whatever state
/// it's in: an incoming challenge waiting on my topic picks, one I sent
/// that's still waiting on the other player, one that's live and ready
/// to play, or one that's finished.
class ChallengeDetailPage extends ConsumerWidget {
  final String challengeId;
  const ChallengeDetailPage({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(challengeDetailProvider(challengeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text('Challenge', style: AppTextStyles.title.copyWith(fontSize: 18)),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Couldn't load this challenge.",
                      style: AppTextStyles.body.copyWith(color: AppColors.subtitle)),
                  const Gap(12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(challengeDetailProvider(challengeId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (detail) => _DetailBody(detail: detail),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final ChallengeDetail detail;
  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(detail: detail),
          const Gap(20),
          switch (detail.status) {
            ChallengeStatus.pending => detail.role == ChallengeRole.opponent
                ? _RespondSection(detail: detail)
                : _WaitingCard(
                    message: '${detail.opponent.name} hasn\'t responded to your challenge yet.',
                  ),
            ChallengeStatus.active => detail.iHaveAnswered
                ? _WaitingCard(
                    message:
                        "You've answered - waiting for ${detail.opponent.name} to finish.",
                  )
                : _PlayCard(detail: detail),
            ChallengeStatus.completed => _ResultsCard(detail: detail),
            ChallengeStatus.declined => _WaitingCard(
                message: detail.role == ChallengeRole.opponent
                    ? 'You declined this challenge.'
                    : '${detail.opponent.name} declined this challenge.',
                icon: Icons.block_rounded,
              ),
            ChallengeStatus.unknown => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ChallengeDetail detail;
  const _HeaderCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_martial_arts_rounded, color: AppColors.primary),
              const Gap(8),
              Expanded(
                child: Text(
                  '${detail.subjectName} Challenge',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              _StatusBadge(status: detail.status),
            ],
          ),
          const Gap(10),
          Text(
            'vs ${detail.opponent.name}',
            style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 13),
          ),
          if (detail.myTopics.isNotEmpty) ...[
            const Gap(12),
            Text('Your topics', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.subtitle)),
            const Gap(6),
            _TopicChips(topics: detail.myTopics),
          ],
          if ((detail.theirTopics ?? const []).isNotEmpty) ...[
            const Gap(12),
            Text('${detail.opponent.name}\'s topics',
                style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.subtitle)),
            const Gap(6),
            _TopicChips(topics: detail.theirTopics!),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ChallengeStatus status;
  const _StatusBadge({required this.status});

  (String, Color) get _labelAndColor {
    switch (status) {
      case ChallengeStatus.pending:
        return ('PENDING', AppColors.warning);
      case ChallengeStatus.active:
        return ('ACTIVE', AppColors.primary);
      case ChallengeStatus.completed:
        return ('DONE', AppColors.success);
      case ChallengeStatus.declined:
        return ('DECLINED', AppColors.danger);
      case ChallengeStatus.unknown:
        return ('', AppColors.subtitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labelAndColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _TopicChips extends StatelessWidget {
  final List<String> topics;
  const _TopicChips({required this.topics});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: topics.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        );
      }).toList(),
    );
  }
}

class _WaitingCard extends StatelessWidget {
  final String message;
  final IconData icon;
  const _WaitingCard({required this.message, this.icon = Icons.hourglass_top_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.subtitle.withValues(alpha: 0.6)),
          const Gap(12),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: AppColors.subtitle)),
        ],
      ),
    );
  }
}

class _PlayCard extends StatelessWidget {
  final ChallengeDetail detail;
  const _PlayCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            '${detail.questionCount} questions ready',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Gap(6),
          Text(
            'Same questions as ${detail.opponent.name} - answer choices are shuffled just for you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChallengePlayPage(
                    challengeId: detail.id,
                    subjectName: detail.subjectName,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
              ),
              child: const Text('Answer Questions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final ChallengeDetail detail;
  const _ResultsCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text('${detail.myScore ?? 0} - ${detail.theirScore ?? 0}', style: AppTextStyles.title.copyWith(fontSize: 26)),
          const Gap(4),
          Text('You vs ${detail.opponent.name}', style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12)),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChallengeResultsPage(challengeId: detail.id)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
              ),
              child: const Text('View Full Results', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

/// The incoming-challenge flow: see the challenger's picked topics, pick
/// my own from what's available for this subject, then accept - or
/// decline outright.
class _RespondSection extends ConsumerStatefulWidget {
  final ChallengeDetail detail;
  const _RespondSection({required this.detail});

  @override
  ConsumerState<_RespondSection> createState() => _RespondSectionState();
}

class _RespondSectionState extends ConsumerState<_RespondSection> {
  final _quizService = QuizService();
  final _challengesService = ChallengesService();

  bool _loadingTopics = true;
  List<TopicOption> _availableTopics = const [];
  final Set<String> _selected = {};

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final topics = await _quizService.getTopics(
        subjectId: widget.detail.subjectId,
        classLevel: widget.detail.classLevel,
      );
      if (mounted) setState(() { _availableTopics = topics; _loadingTopics = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTopics = false);
    }
  }

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      await _challengesService.respond(widget.detail.id, _selected.toList());
      ref.invalidate(challengeDetailProvider(widget.detail.id));
      ref.invalidate(challengesListProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't accept right now - try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Decline challenge?'),
        content: Text('This will end the challenge from ${widget.detail.opponent.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Decline')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await _challengesService.decline(widget.detail.id);
      ref.invalidate(challengeDetailProvider(widget.detail.id));
      ref.invalidate(challengesListProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't decline right now - try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your own topics',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Gap(4),
          Text(
            'Topics you both pick get extra weight in the question set.',
            style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
          ),
          const Gap(14),
          if (_loadingTopics)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else if (_availableTopics.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No specific topics yet for this subject - a random question set will be used.',
                style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTopics.map((t) {
                final selected = _selected.contains(t.topic);
                final sharedWithChallenger = widget.detail.challengerTopics.contains(t.topic);
                return FilterChip(
                  label: Text('${t.topic}${sharedWithChallenger ? ' ⭐' : ''}'),
                  selected: selected,
                  onSelected: _busy
                      ? null
                      : (v) => setState(() => v ? _selected.add(t.topic) : _selected.remove(t.topic)),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: selected ? AppColors.primary : AppColors.text,
                  ),
                  backgroundColor: const Color(0xFFF3F4F6),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _decline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                  ),
                  child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _busy || _loadingTopics ? null : _accept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                  ),
                  child: _busy
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
