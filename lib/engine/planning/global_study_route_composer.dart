import '../../domain/study_route.dart';
import '../../domain/subject.dart';
import '../../domain/subject_study_route.dart';
import '../route/route_selector.dart';
import 'weekly_deficit_subject_selector.dart';

List<SubjectStudyRoute> composeGlobalStudyRoute({
  required Iterable<SubjectStudyRoute> subjectRoutes,
  required Map<SubjectId, double> targetWeightsBySubject,
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
  final workingAllocations = Map<SubjectId, int>.of(allocatedSlotsBySubject);
  final selectedSegments = <SubjectStudyRoute>[];

  var selectedTaskCount = 0;

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

    final selectedRoute = selectNextSubjectByWeeklyDeficit(
      subjectRoutes: nextUnitsByRoute.keys,
      targetWeightsBySubject: targetWeightsBySubject,
      allocatedSlotsBySubject: workingAllocations,
    );

    if (selectedRoute == null) {
      break;
    }

    final selectedUnit = nextUnitsByRoute[selectedRoute]!;
    final selectedUnitTaskCount = selectedUnit.tasks.length;

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
