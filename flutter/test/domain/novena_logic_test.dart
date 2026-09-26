import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/domain/novena_logic.dart';

const _novena = Novena(
  id: 'n1',
  title: 'St. Jude',
  intention: 'For my brother',
  startDate: '2026-05-01',
  createdAt: '2026-05-01T08:00:00.000Z',
);

/// Daily Logs with the Novena prayed on each of [days] (1-based Novena Days).
Map<String, DailyLog> _prayedOn(List<int> days) => {
      for (final d in days)
        '2026-05-${d.toString().padLeft(2, '0')}': DailyLog(
          date: '2026-05-${d.toString().padLeft(2, '0')}',
          completedNovenas: const ['n1'],
        ),
    };

void main() {
  test('a missed Day does not shift the Days that follow', () {
    final status = novenaStatus(_novena, _prayedOn([1, 2, 3]), DateTime(2026, 5, 5));
    expect(status, isA<NovenaInProgress>());
    expect((status as NovenaInProgress).day, 5);
  });

  test('prayed on all nine Days is a Completed Novena once they have passed', () {
    final status = novenaStatus(
      _novena,
      _prayedOn([1, 2, 3, 4, 5, 6, 7, 8, 9]),
      DateTime(2026, 5, 10),
    );
    expect(status, isA<NovenaCompleted>());
  });

  test('a missed middle Day makes it an Incomplete Novena', () {
    final status = novenaStatus(
      _novena,
      _prayedOn([1, 2, 3, 5, 6, 7, 8, 9]),
      DateTime(2026, 5, 12),
    );
    expect(status, isA<NovenaIncomplete>());
    expect((status as NovenaIncomplete).daysPrayed, 8);
  });

  test('a Novena whose start Day is still ahead is upcoming', () {
    final status = novenaStatus(_novena, const {}, DateTime(2026, 4, 29));
    expect(status, isA<NovenaUpcoming>());
  });
}
