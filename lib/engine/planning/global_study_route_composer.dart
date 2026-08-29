import '../../domain/preparation_phase.dart';
import '../../domain/study_route.dart';
import '../../domain/subject.dart';
import '../../domain/subject_study_route.dart';
import '../route/route_selector.dart';
import 'phase_scoped_allocations.dart';
import 'weekly_deficit_subject_selector.dart';

List<SubjectStudyRoute> composeGlobalStudyRoute({
  required Iterable<SubjectStudyRoute> subjectRoutes,
  required Map<SubjectId, double> targetWeightsBySubject,
  required PreparationPhase planPhase,
  required PreparationPhase allocationPhase,
  required Map<SubjectId, int> allocatedSlotsBySubject,
  required RouteSelectionConfig selectionConfig,
}) {
  final remainingRoutes = subjectRoutes
      .map(
        (subjectRoute) => SubjectStudyRoute(
          subjectId: subjectRoute.subjectId,
          route: StudyRoute(
            tasks: List<StudyTask>.unmodifiable(subjectRoute.tasks),
          ),
        ),
      )
      .toList();
  final workingAllocations = Map<SubjectId, int>.of(
    allocationsForPreparationPhase(
      planPhase: planPhase,
      allocationPhase: allocationPhase,
      allocatedSlotsBySubject: allocatedSlotsBySubject,
    ),
  );
  final selectedSegments = <SubjectStudyRoute>[];

  var selectedTaskCount = 0;
  var hasSelectedUrgentUnit = false;

  while (selectedTaskCount < selectionConfig.maxTasks) {
    final remainingCapacity = selectionConfig.maxTasks - selectedTaskCount;
    final nextUnitsByRoute = <SubjectStudyRoute, StudyRoute>{};

    for (final subjectRoute in remainingRoutes) {
      final nextUnit = _selectNextRouteUnit(
        route: subjectRoute.route,
        remainingCapacity: remainingCapacity,
      );

      if (nextUnit.tasks.isNotEmpty) {
        nextUnitsByRoute[subjectRoute] = nextUnit;
      }
    }

    final urgentRoutes = nextUnitsByRoute.entries
        .where((entry) => _isUrgentUnit(entry.value))
        .map((entry) => entry.key)
        .toList(growable: false);
    final eligibleRoutes = !hasSelectedUrgentUnit && urgentRoutes.isNotEmpty
        ? urgentRoutes
        : nextUnitsByRoute.keys;

    final selectedRoute = selectNextSubjectByWeeklyDeficit(
      subjectRoutes: eligibleRoutes,
      targetWeightsBySubject: targetWeightsBySubject,
      allocatedSlotsBySubject: workingAllocations,
    );

    if (selectedRoute == null) {
      break;
    }

    final selectedUnit = nextUnitsByRoute[selectedRoute]!;
    final selectedUnitTaskCount = selectedUnit.tasks.length;
    hasSelectedUrgentUnit =
        hasSelectedUrgentUnit || _isUrgentUnit(selectedUnit);

    selectedSegments.add(
      SubjectStudyRoute(
        subjectId: selectedRoute.subjectId,
        route: selectedUnit,
      ),
    );
    selectedTaskCount += selectedUnitTaskCount;
    workingAllocations.update(
      selectedRoute.subjectId,
      (allocatedSlots) => allocatedSlots + selectedUnitTaskCount,
      ifAbsent: () => selectedUnitTaskCount,
    );

    final selectedRouteIndex = remainingRoutes.indexOf(selectedRoute);
    remainingRoutes[selectedRouteIndex] = SubjectStudyRoute(
      subjectId: selectedRoute.subjectId,
      route: StudyRoute(
        tasks: List<StudyTask>.unmodifiable(
          selectedRoute.tasks.skip(selectedUnitTaskCount),
        ),
      ),
    );
  }

  return List<SubjectStudyRoute>.unmodifiable(selectedSegments);
}

bool _isUrgentUnit(StudyRoute route) {
  return route.tasks.any((task) => task.priority == StudyTaskPriority.urgent);
}

StudyRoute _selectNextRouteUnit({
  required StudyRoute route,
  required int remainingCapacity,
}) {
  if (route.tasks.isEmpty) {
    return const StudyRoute(tasks: []);
  }

  final firstTask = route.tasks.first;
  final requiredCapacity = firstTask.type == StudyTaskType.bridge ? 2 : 1;

  if (requiredCapacity > remainingCapacity) {
    return const StudyRoute(tasks: []);
  }

  return selectRouteTasks(
    route: route,
    config: RouteSelectionConfig(maxTasks: requiredCapacity),
  );
}
