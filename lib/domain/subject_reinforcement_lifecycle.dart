import 'subject.dart';

class SubjectReinforcementLifecycle {
  const SubjectReinforcementLifecycle({
    required this.subjectId,
    required this.startedAt,
    required this.completedInitialReinforcementCount,
    required this.lastReinforcementCompletedAt,
  }) : assert(
         completedInitialReinforcementCount >= 0 &&
             completedInitialReinforcementCount <= 3,
       ),
       assert(
         completedInitialReinforcementCount == 0
             ? lastReinforcementCompletedAt == null
             : lastReinforcementCompletedAt != null,
       );

  final SubjectId subjectId;

  /// When the weekly subject-level reinforcement lifecycle started.
  ///
  /// For Mathematics this is triggered by the student's first completed P1.
  final DateTime startedAt;

  /// Number of completed initial reinforcement steps.
  ///
  /// The subject policy determines how many initial steps are required
  /// before the branch reinforcement phase becomes active.
  ///
  /// Mathematics currently uses three steps. Other supported subjects
  /// currently use two steps.
  final int completedInitialReinforcementCount;

  /// Completion time of the most recent reinforcement task.
  ///
  /// In the branch phase this continues to track the most recent
  /// branch reinforcement completion.
  final DateTime? lastReinforcementCompletedAt;
}
