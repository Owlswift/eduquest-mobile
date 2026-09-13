import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../models/challenge_models.dart';
import '../../services/challenges_service.dart';

/// Both players' results, side by side - only reachable once the
/// challenge has COMPLETED (both sides have submitted their answers).
class ChallengeResultsPage extends ConsumerStatefulWidget {
  final String challengeId;
  const ChallengeResultsPage({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeResultsPage> createState() => _ChallengeResultsPageState();
}

class _ChallengeResultsPageState extends ConsumerState<ChallengeResultsPage> {
  final _service = ChallengesService();
  ChallengeResults? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final results = await _service.getResults(widget.challengeId);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) {
        setState(() => _error = "Couldn't load results - check your connection and try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        automaticallyImplyLeading: false,
        title: Text('Results', style: AppTextStyles.title.copyWith(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Done'),
          ),
        ],
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.subtitle)),
              const Gap(16),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final results = _results;
    if (results == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final headline = results.isDraw
        ? "🤝 It's a tie!"
        : (results.challenger.won || results.opponent.won)
            ? '🎉 ${results.challenger.won ? results.challenger.name : results.opponent.name} wins!'
            : 'Challenge complete';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(headline, style: AppTextStyles.title.copyWith(fontSize: 22)),
          const Gap(24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ResultCard(side: results.challenger)),
              const Gap(14),
              Expanded(child: _ResultCard(side: results.opponent)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ChallengeResultSide side;
  const _ResultCard({required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
        border: side.won ? Border.all(color: AppColors.success, width: 2) : null,
      ),
      child: Column(
        children: [
          if (side.won)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 28),
            ),
          Text(
            side.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Gap(10),
          Text(
            '${side.correctCount}/${side.totalQuestions}',
            style: AppTextStyles.title.copyWith(fontSize: 26),
          ),
          Text(
            'correct',
            style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
          ),
          const Gap(14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _StatChip(label: '+${side.earnedXp} XP', color: AppColors.primary),
              _StatChip(label: '+${side.earnedCoins} coins', color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: color),
      ),
    );
  }
}
