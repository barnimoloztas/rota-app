import 'reinforcement_task.dart';
import 'study_route.dart';

class DailyReinforcementCandidate {
  const DailyReinforcementCandidate({
    required this.id,
    required this.dueAt,
    required this.currentImportance,
    required this.task,
  }) : assert(id != ''),
       assert(currentImportance >= 0.0 && currentImportance <= 1.0);

  /// Stable identifier used only as the final deterministic tie-break.
  final String id;

  final DateTime dueAt;

  /// Current subject or scope importance, normalized to 0.0 - 1.0.
  final double currentImportance;

  final ReinforcementTask task;
}

class DailyPlanDraft {
  const DailyPlanDraft({
    required this.normalRoute,
    required this.reinforcement,
  });

  /// Normal topic-based tasks selected by the existing route selector.
  final StudyRoute normalRoute;

  /// At most one due reinforcement, kept separate from topic-based tasks.
  final DailyReinforcementCandidate? reinforcement;

  int get taskCount {
    return normalRoute.tasks.length + (reinforcement == null ? 0 : 1);
  }
}
