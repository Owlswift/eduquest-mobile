import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../competitions/controllers/competitions_provider.dart';
import '../../../competitions/models/competition.dart';
import '../../../competitions/presentation/pages/competition_leaderboard_page.dart';
import '../../../competitions/services/competitions_service.dart';

class CompetitionsPage extends ConsumerStatefulWidget {
  const CompetitionsPage({super.key});

  @override
  ConsumerState<CompetitionsPage> createState() => _CompetitionsPageState();
}

class _CompetitionsPageState extends ConsumerState<CompetitionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(competitionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: const Color(0xFF2563EB),
            pinned: true,
            automaticallyImplyLeading: false,
            title: const Text(
              'Competitions',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.emoji_events_rounded,
                    color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15),
              tabs: const [
                Tab(text: 'Ongoing'),
                Tab(text: 'Upcoming'),
              ],
            ),
          ),
        ],
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Couldn't load competitions.",
                    style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                  ),
                  const Gap(12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(competitionsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (competitions) {
            final ongoing = competitions.where((c) => c.isOngoing).toList();
            final upcoming = competitions.where((c) => c.isUpcoming).toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _CompetitionList(competitions: ongoing, isOngoing: true),
                _CompetitionList(competitions: upcoming, isOngoing: false),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompetitionList extends StatelessWidget {
  final List<Competition> competitions;
  final bool isOngoing;

  const _CompetitionList(
      {required this.competitions, required this.isOngoing});

  @override
  Widget build(BuildContext context) {
    if (competitions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty_rounded,
                size: 60, color: AppColors.subtitle.withValues(alpha: 0.4)),
            const Gap(16),
            Text('No ${isOngoing ? 'ongoing' : 'upcoming'} competitions',
                style: AppTextStyles.body),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: competitions.length,
      itemBuilder: (context, index) =>
          _CompetitionCard(competition: competitions[index]),
    );
  }
}

class _CompetitionCard extends ConsumerStatefulWidget {
  final Competition competition;

  const _CompetitionCard({required this.competition});

  @override
  ConsumerState<_CompetitionCard> createState() => _CompetitionCardState();
}

class _CompetitionCardState extends ConsumerState<_CompetitionCard> {
  late Timer _timer;
  late Duration _remaining;
  bool _joining = false;

  /// Ongoing competitions count down to when they end; upcoming ones count
  /// down to when they start - joining early is allowed, so the countdown
  /// tells an already-joined student when things kick off.
  DateTime get _countdownTarget =>
      widget.competition.isOngoing ? widget.competition.endsAt : widget.competition.startsAt;

  @override
  void initState() {
    super.initState();
    _remaining = _countdownTarget.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = _countdownTarget.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      await CompetitionsService().join(widget.competition.id);
      ref.invalidate(competitionsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't join right now - try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  void _openLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompetitionLeaderboardPage(
          competitionId: widget.competition.id,
          competitionTitle: widget.competition.title,
        ),
      ),
    );
  }

  /// True once there's nothing left to *do* on this button - already
  /// joined, so it gets the quieter white/outlined treatment instead of
  /// solid blue.
  bool get _isDone => widget.competition.isJoined;

  String get _buttonLabel {
    if (!widget.competition.isJoined) return 'Join Now';
    return widget.competition.isOngoing ? 'View Leaderboard' : 'Joined ✓';
  }

  @override
  Widget build(BuildContext context) {
    final d = _remaining;
    final timeStr = d.isNegative
        ? '0d : 00h : 00m : 00s'
        : '${d.inDays}d : ${d.inHours.remainder(24).toString().padLeft(2, '0')}h : ${d.inMinutes.remainder(60).toString().padLeft(2, '0')}m : ${d.inSeconds.remainder(60).toString().padLeft(2, '0')}s';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top gradient banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.large),
                topRight: Radius.circular(AppRadius.large),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Color(0xFFFBBF24), size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.competition.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  widget.competition.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.competition.participantCount} joined',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.competition.isOngoing
                            ? 'Ends in $timeStr'
                            : 'Starts in $timeStr',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Prizes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Prizes',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    fontSize: 14,
                  ),
                ),
                const Gap(10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.competition.prizes.map((prize) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        prize,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Gap(14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _joining
                        ? null
                        : !widget.competition.isJoined
                            ? _join
                            : widget.competition.isOngoing
                                ? _openLeaderboard
                                : null, // Already joined, waiting for it to start.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDone ? Colors.white : AppColors.primary,
                      foregroundColor: _isDone ? AppColors.primary : Colors.white,
                      elevation: 0,
                      side: _isDone
                          ? const BorderSide(color: AppColors.primary, width: 1.5)
                          : BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: _joining
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _isDone ? AppColors.primary : Colors.white),
                            ),
                          )
                        : Text(
                            _buttonLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
