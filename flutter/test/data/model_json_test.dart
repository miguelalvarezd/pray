import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/data/models/activity.dart';
import 'package:pray/data/models/activity_category.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/data/models/priority.dart';

void main() {
  test('Intention round-trips through JSON', () {
    final i = Intention(
      id: 'a',
      title: 'T',
      description: 'D',
      createdAt: '2026-04-01T00:00:00.000Z',
      targetDate: '2026-12-25',
      priority: Priority.high,
    );
    final j = i.toJson();
    final back = Intention.fromJson(j);
    expect(back.id, i.id);
    expect(back.title, i.title);
    expect(back.description, i.description);
    expect(back.createdAt, i.createdAt);
    expect(back.targetDate, i.targetDate);
    expect(back.priority, i.priority);
    expect(back.status, i.status);
  });

  test('Novena round-trips through JSON', () {
    const n = Novena(
      id: 'n',
      title: 'St. Jude',
      intention: 'For Z',
      startDate: '2026-04-25',
      createdAt: '2026-04-25T00:00:00.000Z',
      prayer: 'May the Sacred Heart…',
      templateId: 'st-jude',
    );
    final back = Novena.fromJson(n.toJson());
    expect(back.title, n.title);
    expect(back.templateId, n.templateId);
  });

  test('DailyLog handles optional fields', () {
    const log = DailyLog(
      date: '2026-04-30',
      completedPrayers: ['mass'],
      completedIntentions: [],
    );
    final back = DailyLog.fromJson(log.toJson());
    expect(back.date, log.date);
    expect(back.completedPrayers, ['mass']);
    expect(back.completedNovenas, isNull);
    expect(back.gratitudeEntry, isNull);
  });

  test('Activity round-trips', () {
    const a = Activity(
      id: 'fasting',
      name: 'Fasting',
      icon: 'UtensilsCrossed',
      category: ActivityCategory.spiritual,
    );
    final back = Activity.fromJson(a.toJson());
    expect(back.id, a.id);
    expect(back.category, ActivityCategory.spiritual);
  });

  test('Priority.fromJson tolerates unknown values', () {
    expect(Priority.fromJson('bogus'), Priority.medium);
  });
}
