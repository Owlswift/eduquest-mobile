import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../dashboard/controllers/subjects_provider.dart';
import '../../../dashboard/controllers/user_profile_provider.dart';
import '../../../dashboard/models/dashboard_models.dart';
import '../../../dashboard/presentation/pages/subjects_page.dart' show subjectIconSvg;
import '../../../quiz/models/quiz_models.dart';
import '../../../quiz/services/quiz_service.dart';
import '../../controllers/challenges_provider.dart';
import '../../models/challenge_models.dart';
import '../../services/challenges_service.dart';
import 'challenge_detail_page.dart';

/// A picked opponent, whether they came from the matchmaking suggestions
/// (pseudonymous) or a manual username search (real name).
class _PickedOpponent {
  final String userId;
  final String displayName;
  const _PickedOpponent({required this.userId, required this.displayName});
}

/// Create Challenge: pick a subject first (so matchmaking has something
/// to rank against), then an opponent - either one of EduQuest's
/// suggestions (ranked by similar subject ability, topic overlap, and
/// activity, shown pseudonymously) or a specific student by username -
/// then optionally the topics to weight the question pool toward.
class NewChallengePage extends ConsumerStatefulWidget {
  const NewChallengePage({super.key});

  @override
  ConsumerState<NewChallengePage> createState() => _NewChallengePageState();
}

class _NewChallengePageState extends ConsumerState<NewChallengePage> {
  final _challengesService = ChallengesService();
  final _quizService = QuizService();

  SubjectModel? _subject;

  bool _loadingSuggestions = false;
  ChallengeSuggestions? _suggestions;
  bool _manualSearch = false;

  final _searchController = TextEditingController();
  Timer? _debounce;
  List<ChallengeOpponentCandidate> _searchResults = [];
  bool _searching = false;

  _PickedOpponent? _opponent;

  bool _loadingTopics = false;
  List<TopicOption> _availableTopics = const [];
  final Set<String> _selectedTopics = {};

  bool _sending = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickSubject() async {
    final subjectsAsync = ref.read(subjectsProvider);
    final allSubjects = subjectsAsync.valueOrNull;
    if (allSubjects == null || allSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subjects are still loading - try again in a moment.')),
      );
      return;
    }

    // JSS and SS subjects can share a display name (e.g. both "Business
    // Studies") - only the "jss_"-prefixed id marks a JSS subject, since
    // Subject has no first-class track field. Scope the list to the
    // student's own track so JSS/SS duplicates don't both show up here.
    final myClassLevel = ref.read(userProfileProvider).valueOrNull?.classLevel;
    final isJss = (myClassLevel ?? 'SS1').startsWith('JSS');
    final scoped = allSubjects.where((s) => s.id.startsWith('jss_') == isJss).toList();
    final subjects = scoped.isNotEmpty ? scoped : allSubjects;

    final picked = await showModalBottomSheet<SubjectModel>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Challenge which subject?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.5),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: subjects.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final s = subjects[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: SizedBox(width: 32, height: 32, child: SvgPicture.string(subjectIconSvg(s.id))),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () => Navigator.of(sheetContext).pop(s),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _subject = picked;
      _opponent = null;
      _manualSearch = false;
      _searchResults = [];
      _availableTopics = const [];
      _selectedTopics.clear();
      _loadingSuggestions = true;
      _loadingTopics = true;
    });

    final classLevel = ref.read(userProfileProvider).valueOrNull?.classLevel;
    final effectiveClassLevel = (classLevel == null || classLevel.isEmpty) ? 'SS1' : classLevel;

    unawaited(() async {
      try {
        final suggestions = await _challengesService.getSuggestions(picked.id);
        if (mounted) setState(() { _suggestions = suggestions; _loadingSuggestions = false; });
      } catch (_) {
        if (mounted) setState(() => _loadingSuggestions = false);
      }
    }());

    unawaited(() async {
      try {
        final topics = await _quizService.getTopics(subjectId: picked.id, classLevel: effectiveClassLevel);
        if (mounted) setState(() { _availableTopics = topics; _loadingTopics = false; });
      } catch (_) {
        if (mounted) setState(() => _loadingTopics = false);
      }
    }());
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await _challengesService.searchOpponents(query, subjectId: _subject?.id);
      if (mounted) setState(() => _searchResults = results);
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  bool get _canSend => _opponent != null && _subject != null && !_sending;

  Future<void> _send() async {
    if (!_canSend) return;
    setState(() => _sending = true);
    try {
      final id = await _challengesService.create(
        opponentId: _opponent!.userId,
        subjectId: _subject!.id,
        topics: _selectedTopics.toList(),
      );
      ref.invalidate(challengesListProvider);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ChallengeDetailPage(challengeId: id)),
      );
    } on DioException catch (e) {
      // Surface the real reason (e.g. a different class level, or an
      // open challenge already existing) rather than a generic error -
      // eligibility is enforced server-side regardless of what the
      // suggestions/search list already filtered out.
      final message = (e.response?.data is Map) ? (e.response?.data['message']?.toString()) : null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? "Couldn't send the challenge - try again.")),
        );
        setState(() => _sending = false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't send the challenge - try again.")),
        );
        setState(() => _sending = false);
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
        title: Text('New Challenge', style: AppTextStyles.title.copyWith(fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('1. Subject'),
              const Gap(10),
              GestureDetector(
                onTap: _pickSubject,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      if (_subject != null)
                        SizedBox(width: 28, height: 28, child: SvgPicture.string(subjectIconSvg(_subject!.id)))
                      else
                        const Icon(Icons.menu_book_rounded, color: AppColors.subtitle),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          _subject?.name ?? 'Choose a subject',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _subject == null ? AppColors.subtitle : AppColors.text,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.subtitle),
                    ],
                  ),
                ),
              ),

              if (_subject != null) ...[
                const Gap(24),
                _SectionLabel('2. Opponent'),
                const Gap(10),
                if (_opponent != null)
                  _SelectedOpponentTile(
                    name: _opponent!.displayName,
                    onClear: () => setState(() => _opponent = null),
                  )
                else if (_manualSearch)
                  _ManualSearchSection(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    searching: _searching,
                    results: _searchResults,
                    onPick: (c) => setState(() {
                      _opponent = _PickedOpponent(userId: c.id, displayName: c.fullName);
                      _searchResults = [];
                      _searchController.clear();
                    }),
                    onBackToSuggestions: () => setState(() => _manualSearch = false),
                  )
                else
                  _SuggestionsSection(
                    loading: _loadingSuggestions,
                    suggestions: _suggestions,
                    onPick: (s) => setState(() {
                      _opponent = _PickedOpponent(userId: s.userId, displayName: s.pseudonym);
                    }),
                    onSearchInstead: () => setState(() => _manualSearch = true),
                  ),
              ],

              if (_subject != null && _opponent != null) ...[
                const Gap(24),
                _SectionLabel('3. Topics (optional)'),
                const Gap(6),
                Text(
                  'Pick what you want to be tested on. Topics you both pick get extra weight.',
                  style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
                ),
                const Gap(10),
                if (_loadingTopics)
                  const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                else if (_availableTopics.isEmpty)
                  Text(
                    'No specific topics yet for this subject - a random question set will be used.',
                    style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTopics.map((t) {
                      final selected = _selectedTopics.contains(t.topic);
                      return FilterChip(
                        label: Text(t.topic),
                        selected: selected,
                        onSelected: (v) => setState(() => v ? _selectedTopics.add(t.topic) : _selectedTopics.remove(t.topic)),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: selected ? AppColors.primary : AppColors.text,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                const Gap(28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSend ? _send : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      disabledForegroundColor: AppColors.subtitle,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                    ),
                    child: _sending
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Send Challenge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14));
  }
}

/// EduQuest's ranked opponent picks - "Recommended" (top matches) and
/// "Discover" (a wider, more random band), both pseudonymous.
class _SuggestionsSection extends StatelessWidget {
  final bool loading;
  final ChallengeSuggestions? suggestions;
  final ValueChanged<SuggestedOpponent> onPick;
  final VoidCallback onSearchInstead;

  const _SuggestionsSection({
    required this.loading,
    required this.suggestions,
    required this.onPick,
    required this.onSearchInstead,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }

    final s = suggestions;
    final hasAny = s != null && (s.recommended.isNotEmpty || s.discover.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasAny)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "No suggestions yet - not enough students studying this subject. Try searching for someone instead.",
              style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
            ),
          )
        else ...[
          if (s.recommended.isNotEmpty) ...[
            Text('RECOMMENDED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.subtitle, letterSpacing: 0.5)),
            const Gap(8),
            ...s.recommended.map((o) => _SuggestionTile(opponent: o, onTap: () => onPick(o))),
          ],
          if (s.discover.isNotEmpty) ...[
            const Gap(12),
            Text('DISCOVER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.subtitle, letterSpacing: 0.5)),
            const Gap(8),
            ...s.discover.map((o) => _SuggestionTile(opponent: o, onTap: () => onPick(o))),
          ],
        ],
        const Gap(12),
        Center(
          child: TextButton(
            onPressed: onSearchInstead,
            child: const Text('Search by username instead', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final SuggestedOpponent opponent;
  final VoidCallback onTap;
  const _SuggestionTile({required this.opponent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFF3F4F6),
                    child: Icon(Icons.person_rounded, color: AppColors.subtitle),
                  ),
                  if (opponent.activeToday)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opponent.pseudonym, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(
                      opponent.abilityPercent != null ? '${opponent.abilityPercent}% ability' : 'New to this subject',
                      style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Challenge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool searching;
  final List<ChallengeOpponentCandidate> results;
  final ValueChanged<ChallengeOpponentCandidate> onPick;
  final VoidCallback onBackToSuggestions;

  const _ManualSearchSection({
    required this.controller,
    required this.onChanged,
    required this.searching,
    required this.results,
    required this.onPick,
    required this.onBackToSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search by username or name…',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (searching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: AppShadows.card,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final candidate = results[i];
                // Ineligible students still show up (hiding them would
                // just look like search can't find them) - they're
                // dimmed and labeled with why, and tapping explains
                // rather than silently doing nothing.
                return Opacity(
                  opacity: candidate.eligible ? 1 : 0.55,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Icons.person_rounded, color: AppColors.subtitle),
                    ),
                    title: Text(candidate.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      candidate.eligible ? '@${candidate.username}' : candidate.ineligibleReason ?? 'Not eligible',
                      style: candidate.eligible
                          ? null
                          : const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                    ),
                    trailing: candidate.eligible ? null : const Icon(Icons.block_rounded, color: AppColors.danger, size: 18),
                    onTap: candidate.eligible
                        ? () => onPick(candidate)
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(candidate.ineligibleReason ?? "You can't challenge this student right now.")),
                            ),
                  ),
                );
              },
            ),
          ),
        const Gap(8),
        Center(
          child: TextButton(
            onPressed: onBackToSuggestions,
            child: const Text('Back to suggestions', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _SelectedOpponentTile extends StatelessWidget {
  final String name;
  final VoidCallback onClear;
  const _SelectedOpponentTile({required this.name, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFF3F4F6),
            child: Icon(Icons.person_rounded, color: AppColors.subtitle),
          ),
          const Gap(12),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          IconButton(onPressed: onClear, icon: const Icon(Icons.close_rounded)),
        ],
      ),
    );
  }
}
