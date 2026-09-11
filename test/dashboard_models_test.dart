import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/models/daily_summary.dart';
import 'package:mobile/features/dashboard/models/leaderboard.dart';
import 'package:mobile/features/dashboard/models/user_profile.dart';
import 'package:mobile/features/tutor/models/tutor_models.dart';

void main() {
  group('UserProfile', () {
    test('parses /users/me and derives first name + progress', () {
      final p = UserProfile.fromJson({
        'fullName': 'ola law',
        'coins': 130,
        'xp': 80,
        'maxXp': 500,
        'level': 1,
        'streak': 3,
        'subjects': ['math', 'english'],
      });

      expect(p.firstName, 'Ola');
      expect(p.coins, 130);
      expect(p.levelProgress, closeTo(80 / 500, 1e-9));
      expect(p.subjects, ['math', 'english']);
    });

    test('falls back gracefully on missing / zero fields', () {
      final p = UserProfile.fromJson({});
      expect(p.firstName, 'there');
      expect(p.maxXp, 500); // 0 -> sensible default
      expect(p.levelProgress, 0);
      expect(p.subjects, isEmpty);
    });
  });

  group('DailySummary', () {
    test('parses streak, goal and the week strip', () {
      final s = DailySummary.fromJson({
        'streak': 3,
        'goal': {'target': 20, 'answeredToday': 10, 'percent': 50},
        'week': [
          {'date': '2026-06-15', 'weekday': 'Mon', 'studied': true, 'isToday': false},
          {'date': '2026-06-17', 'weekday': 'Wed', 'studied': true, 'isToday': true},
        ],
      });

      expect(s.streak, 3);
      expect(s.goalTarget, 20);
      expect(s.goalAnswered, 10);
      expect(s.goalPercent, 50);
      expect(s.week, hasLength(2));
      expect(s.week[1].isToday, isTrue);
      expect(s.week[1].weekday, 'Wed');
    });

    test('empty payload yields safe defaults', () {
      final s = DailySummary.fromJson({});
      expect(s.streak, 0);
      expect(s.goalTarget, 20);
      expect(s.week, isEmpty);
    });
  });

  group('LeaderboardData', () {
    test('parses top rows and the me entry', () {
      final d = LeaderboardData.fromJson({
        'top': [
          {'rank': 1, 'name': 'Aisha', 'xp': 300, 'isMe': false},
          {'rank': 2, 'name': 'Ola', 'xp': 120, 'isMe': true},
        ],
        'me': {'rank': 2, 'name': 'Ola', 'xp': 120},
      });

      expect(d.top, hasLength(2));
      expect(d.top.first.name, 'Aisha');
      expect(d.top[1].isMe, isTrue);
      expect(d.me?.rank, 2);
    });

    test('handles a null me entry', () {
      final d = LeaderboardData.fromJson({'top': [], 'me': null});
      expect(d.top, isEmpty);
      expect(d.me, isNull);
    });
  });

  group('InProgressTopic', () {
    test('parses the nested topic + progress', () {
      final t = InProgressTopic.fromJson({
        'sessionId': 's1',
        'state': 'EXPLAIN_CONCEPT',
        'progressPercent': 33,
        'topic': {
          'id': 't1',
          'subjectId': 'math',
          'classLevel': 'SS1',
          'theme': 'Algebraic Processes',
          'topic': 'Sets',
        },
      });

      expect(t.sessionId, 's1');
      expect(t.progressPercent, 33);
      expect(t.topic.subjectId, 'math');
      expect(t.topic.topic, 'Sets');
    });
  });
}
