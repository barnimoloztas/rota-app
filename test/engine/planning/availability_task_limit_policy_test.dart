import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_study_availability.dart';
import 'package:rota_app/engine/planning/availability_task_limit_policy.dart';

void main() {
  group('taskLimitForAvailability', () {
    test('maps approximate availability to daily task limit', () {
      expect(
        taskLimitForAvailability(
          DailyStudyAvailability.aboutOneHour,
        ),
        1,
      );

      expect(
        taskLimitForAvailability(
          DailyStudyAvailability.aboutTwoHours,
        ),
        2,
      );

      expect(
        taskLimitForAvailability(
          DailyStudyAvailability.aboutThreeHours,
        ),
        3,
      );

      expect(
        taskLimitForAvailability(
          DailyStudyAvailability.fourHoursOrMore,
        ),
        4,
      );
    });

    test('uses three tasks as the standard when availability is unspecified', () {
      expect(
        taskLimitForAvailability(
          DailyStudyAvailability.unspecified,
        ),
        3,
      );
    });
  });
}