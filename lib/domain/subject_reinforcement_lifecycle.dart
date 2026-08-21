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
  /// 0 -> R1 not completed
  /// 1 -> R1 completed
  /// 2 -> R2 completed
  /// 3 -> R1-R3 completed; branch reinforcement phase is active
  final int completedInitialReinforcementCount;

  /// Completion time of the most recent reinforcement task.
  ///
  /// After R3 this continues to track the most recent
  /// branch reinforcement completion.
  final DateTime? lastReinforcementCompletedAt;
}
