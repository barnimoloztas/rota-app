import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_day.dart';

void main() {
  group('resolveStudyDay', () {
    test('before 08:00 continues previous study day without manual advance', () {
      final context = StudyDayContext(
        now: DateTime(2026, 8, 14, 3, 0),
        lastManualAdvanceAt: null,
      );

      final result = resolveStudyDay(context);

      expect(
        result.date,
        DateTime(2026, 8, 13),
      );
    });

    test('07:59 still belongs to previous study day', () {
      final context = StudyDayContext(
        now: DateTime(2026, 8, 14, 7, 59),
        lastManualAdvanceAt: null,
      );

      final result = resolveStudyDay(context);

      expect(
        result.date,
        DateTime(2026, 8, 13),
      );
    });

    test('08:00 automatically starts current calendar day', () {
      final context = StudyDayContext(
        now: DateTime(2026, 8, 14, 8, 0),
        lastManualAdvanceAt: null,
      );

      final result = resolveStudyDay(context);

      expect(
        result.date,
        DateTime(2026, 8, 14),
      );
    });

    test('after 08:00 belongs to current study day', () {
      final context = StudyDayContext(
        now: DateTime(2026, 8, 14, 14, 30),
        lastManualAdvanceAt: null,
      );

      final result = resolveStudyDay(context);

      expect(
        result.date,
        DateTime(2026, 8, 14),
      );
    });

    test('manual advance before 08:00 starts current study day early', () {
      final context = StudyDayContext(
        now: DateTime(2026, 8, 14, 3, 0),
        lastManualAdvanceAt: DateTime(2026, 8, 14, 2, 45),
      );

      final result = resolveStudyDay(context);

      expect(
        result.date,
        DateTime(2026, 8, 14),
      );
    });

    test(
      'manual advance from previous calendar day does not affect new early morning',
      () {
        final context = StudyDayContext(
          now: DateTime(2026, 8, 14, 3, 0),
          lastManualAdvanceAt: DateTime(2026, 8, 13, 22, 0),
        );

        final result = resolveStudyDay(context);

        expect(
          result.date,
          DateTime(2026, 8, 13),
        );
      },
    );

    test('midnight does not automatically start a new study day', () {
      final context = StudyDayContext(
        now: DateTime(2026, 8, 14, 0, 0),
        lastManualAdvanceAt: null,
      );

      final result = resolveStudyDay(context);

      expect(
        result.date,
        DateTime(2026, 8, 13),
      );
    });

    test('same input always resolves to same study day', () {
      final context = StudyDayContext(
        now: DateTime(2026, 8, 14, 6, 30),
        lastManualAdvanceAt: null,
      );

      final first = resolveStudyDay(context);
      final second = resolveStudyDay(context);

      expect(first.date, second.date);
    });
  });
}