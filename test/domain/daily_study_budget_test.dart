import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_study_budget.dart';

void main() {
  group('DailyStudyBudget', () {
    test('stores available study minutes', () {
      const budget = DailyStudyBudget(
        availableMinutes: 120,
      );

      expect(budget.availableMinutes, 120);
      expect(budget.hasNoAvailableTime, isFalse);
    });

    test('reports no available time when budget is zero', () {
      const budget = DailyStudyBudget(
        availableMinutes: 0,
      );

      expect(budget.availableMinutes, 0);
      expect(budget.hasNoAvailableTime, isTrue);
    });

    test('positive budget is not treated as zero-time day', () {
      const budget = DailyStudyBudget(
        availableMinutes: 45,
      );

      expect(budget.hasNoAvailableTime, isFalse);
    });
  });
}