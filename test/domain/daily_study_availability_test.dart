import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_study_availability.dart';

void main() {
  group('DailyStudyAvailability', () {
    test('represents approximate daily study availability', () {
      expect(
        DailyStudyAvailability.values,
        containsAllInOrder([
          DailyStudyAvailability.aboutOneHour,
          DailyStudyAvailability.aboutTwoHours,
          DailyStudyAvailability.aboutThreeHours,
          DailyStudyAvailability.fourHoursOrMore,
          DailyStudyAvailability.unspecified,
        ]),
      );
    });
  });
}