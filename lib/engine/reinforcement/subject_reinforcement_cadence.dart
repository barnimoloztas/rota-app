import '../../domain/subject.dart';

class SubjectReinforcementCadence {
  const SubjectReinforcementCadence({
    required this.firstDueAfterDays,
    required this.repeatEveryDays,
    required this.topicReinforcementCount,
  }) : assert(firstDueAfterDays > 0),
       assert(repeatEveryDays > 0),
       assert(topicReinforcementCount > 0),
       assert(topicReinforcementCount <= 3);

  final int firstDueAfterDays;
  final int repeatEveryDays;
  final int topicReinforcementCount;
}

SubjectReinforcementCadence subjectReinforcementCadenceFor(
  SubjectId subjectId,
) {
  return switch (subjectId) {
    'mathematics' => const SubjectReinforcementCadence(
      firstDueAfterDays: 14,
      repeatEveryDays: 7,
      topicReinforcementCount: 3,
    ),
    'physics' => const SubjectReinforcementCadence(
      firstDueAfterDays: 14,
      repeatEveryDays: 14,
      topicReinforcementCount: 2,
    ),
    'chemistry' => const SubjectReinforcementCadence(
      firstDueAfterDays: 21,
      repeatEveryDays: 21,
      topicReinforcementCount: 2,
    ),
    'biology' => const SubjectReinforcementCadence(
      firstDueAfterDays: 30,
      repeatEveryDays: 30,
      topicReinforcementCount: 2,
    ),
    'turkish' => const SubjectReinforcementCadence(
      firstDueAfterDays: 21,
      repeatEveryDays: 21,
      topicReinforcementCount: 2,
    ),
    _ => throw ArgumentError.value(
      subjectId,
      'subjectId',
      'Subject reinforcement cadence is not defined.',
    ),
  };
}
