import 'reinforcement_task.dart';
import 'study_route.dart';
import 'subject_plan_task.dart';

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
    this.protectedSubjectTasks = const [],
    required this.normalSubjectTasks,
    required this.reinforcement,
  });

  /// Preselected academic tasks that the daily composer must not displace.
  final List<SubjectPlanTask> protectedSubjectTasks;

  /// Normal topic-based tasks selected for this plan, with subject identity.
  final List<SubjectPlanTask> normalSubjectTasks;

  /// At most one due reinforcement, kept separate from topic-based tasks.
  final DailyReinforcementCandidate? reinforcement;

  /// Backward-compatible view for consumers that only need study tasks.
  List<StudyTask> get protectedTasks {
    return List<StudyTask>.unmodifiable(
      protectedSubjectTasks.map((plannedTask) => plannedTask.task),
    );
  }

  /// Backward-compatible view for consumers that only need the normal route.
  StudyRoute get normalRoute {
    return StudyRoute(
      tasks: List<StudyTask>.unmodifiable(
        normalSubjectTasks.map((plannedTask) => plannedTask.task),
      ),
    );
  }

  int get taskCount {
    return protectedSubjectTasks.length +
        normalSubjectTasks.length +
        (reinforcement == null ? 0 : 1);
  }
}
