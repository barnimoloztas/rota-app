import '../../domain/daily_plan_draft.dart';
import '../../domain/study_route.dart';
import '../../domain/subject_plan_task.dart';
import '../route/route_selector.dart';

const _maximumDailyTaskCount = 4;

DailyPlanDraft composeUntouchedDailyPlan({
  required Iterable<SubjectPlanTask> rankedNormalTasks,
  required Iterable<DailyReinforcementCandidate> reinforcementCandidates,
  required DateTime evaluatedAt,
}) {
  return composeDailyPlan(
    protectedSubjectTasks: const [],
    rankedNormalTasks: rankedNormalTasks,
    reinforcementCandidates: reinforcementCandidates,
    evaluatedAt: evaluatedAt,
  );
}

DailyPlanDraft composeDailyPlan({
  required Iterable<SubjectPlanTask> protectedSubjectTasks,
  required Iterable<SubjectPlanTask> rankedNormalTasks,
  required Iterable<DailyReinforcementCandidate> reinforcementCandidates,
  required DateTime evaluatedAt,
}) {
  final preservedTasks = List<SubjectPlanTask>.unmodifiable(
    protectedSubjectTasks,
  );
  final rankedTasks = List<SubjectPlanTask>.unmodifiable(rankedNormalTasks);

  if (preservedTasks.length > _maximumDailyTaskCount) {
    throw ArgumentError.value(
      preservedTasks.length,
      'protectedSubjectTasks',
      'Protected tasks cannot exceed the daily task ceiling.',
    );
  }

  final dueReinforcements =
      reinforcementCandidates
          .where((candidate) => !candidate.dueAt.isAfter(evaluatedAt))
          .toList()
        ..sort(_compareReinforcements);

  final capacityAfterProtectedTasks =
      _maximumDailyTaskCount - preservedTasks.length;
  final selectedReinforcement =
      capacityAfterProtectedTasks == 0 || dueReinforcements.isEmpty
      ? null
      : dueReinforcements.first;
  final normalTaskCapacity =
      capacityAfterProtectedTasks - (selectedReinforcement == null ? 0 : 1);

  final selectedNormalRoute = selectRouteTasks(
    route: StudyRoute(
      tasks: List<StudyTask>.unmodifiable(
        rankedTasks.map((plannedTask) => plannedTask.task),
      ),
    ),
    config: RouteSelectionConfig(maxTasks: normalTaskCapacity),
  );
  final selectedNormalTasks = List<SubjectPlanTask>.unmodifiable(
    rankedTasks.take(selectedNormalRoute.tasks.length),
  );

  return DailyPlanDraft(
    protectedSubjectTasks: preservedTasks,
    normalSubjectTasks: selectedNormalTasks,
    reinforcement: selectedReinforcement,
  );
}

int _compareReinforcements(
  DailyReinforcementCandidate a,
  DailyReinforcementCandidate b,
) {
  final dueComparison = a.dueAt.compareTo(b.dueAt);

  if (dueComparison != 0) {
    return dueComparison;
  }

  final importanceComparison = b.currentImportance.compareTo(
    a.currentImportance,
  );

  if (importanceComparison != 0) {
    return importanceComparison;
  }

  return a.id.compareTo(b.id);
}
