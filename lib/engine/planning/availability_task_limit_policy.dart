import '../../domain/daily_study_availability.dart';

int taskLimitForAvailability(
  DailyStudyAvailability availability,
) {
  switch (availability) {
    case DailyStudyAvailability.aboutOneHour:
      return 1;

    case DailyStudyAvailability.aboutTwoHours:
      return 2;

    case DailyStudyAvailability.aboutThreeHours:
      return 3;

    case DailyStudyAvailability.fourHoursOrMore:
      return 4;

    case DailyStudyAvailability.unspecified:
      return 3;
  }
}