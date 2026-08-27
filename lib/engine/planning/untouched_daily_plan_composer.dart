import '../../domain/daily_plan_draft.dart';
import '../../domain/study_route.dart';
import '../route/route_selector.dart';

const _maximumDailyTaskCount = 4;

DailyPlanDraft composeUntouchedDailyPlan({
  required StudyRoute rankedNormalRoute,
  required Iterable<DailyReinforcementCandidate> reinforcementCandidates,
  required DateTime evaluatedAt,
}) {
  final dueReinforcements =
      reinforcementCandidates
          .where((candidate) => !candidate.dueAt.isAfter(evaluatedAt))
          .toList()
        ..sort(_compareReinforcements);

  final selectedReinforcement = dueReinforcements.isEmpty
      ? null
      : dueReinforcements.first;
  final normalTaskCapacity =
      _maximumDailyTaskCount - (selectedReinforcement == null ? 0 : 1);

  final normalRoute = selectRouteTasks(
    route: rankedNormalRoute,
    config: RouteSelectionConfig(maxTasks: normalTaskCapacity),
  );

  return DailyPlanDraft(
    normalRoute: normalRoute,
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
