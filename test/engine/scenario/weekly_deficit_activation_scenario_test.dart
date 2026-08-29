import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_study_route.dart';
import 'package:rota_app/engine/planning/daily_plan_activation.dart';
import 'package:rota_app/engine/planning/global_study_route_composer.dart';
import 'package:rota_app/engine/planning/subject_plan_task_mapper.dart';
import 'package:rota_app/engine/planning/untouched_daily_plan_composer.dart';
import 'package:rota_app/engine/route/route_selector.dart';

void main() {
  SubjectStudyRoute subjectRoute({
    required String subjectId,
    required String topicId,
  }) {
    return SubjectStudyRoute(
      subjectId: subjectId,
      route: StudyRoute(
        tasks: [
          StudyTask(
            topicId: topicId,
            type: StudyTaskType.practice,
            sourceTopicId: topicId,
          ),
        ],
      ),
    );
  }

  test('active allocation changes the next weekly deficit subject', () {
    final firstSegments = composeGlobalStudyRoute(
      subjectRoutes: [
        subjectRoute(subjectId: 'mathematics', topicId: 'math-1'),
        subjectRoute(subjectId: 'physics', topicId: 'physics-1'),
      ],
      targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
      allocatedSlotsBySubject: const {},
      selectionConfig: const RouteSelectionConfig(maxTasks: 1),
    );
    final firstDraft = composeUntouchedDailyPlan(
      rankedNormalTasks: subjectPlanTasksFromRoutes(firstSegments),
      reinforcementCandidates: const [],
      evaluatedAt: DateTime.utc(2026, 8, 28),
    );

    expect(firstDraft.normalSubjectTasks.single.subjectId, 'mathematics');

    final firstActivation = activateDailyPlan(
      lifecycle: PlanLifecycle.draftUntouched,
      dailyPlan: firstDraft,
      planPhase: PreparationPhase.early,
      allocationPhase: PreparationPhase.early,
      allocatedSlotsBySubject: const {},
    );

    expect(firstActivation.allocatedSlotsBySubject, {'mathematics': 1});

    final secondSegments = composeGlobalStudyRoute(
      subjectRoutes: [
        subjectRoute(subjectId: 'mathematics', topicId: 'math-2'),
        subjectRoute(subjectId: 'physics', topicId: 'physics-2'),
      ],
      targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
      allocatedSlotsBySubject: firstActivation.allocatedSlotsBySubject,
      selectionConfig: const RouteSelectionConfig(maxTasks: 1),
    );
    final secondDraft = composeUntouchedDailyPlan(
      rankedNormalTasks: subjectPlanTasksFromRoutes(secondSegments),
      reinforcementCandidates: const [],
      evaluatedAt: DateTime.utc(2026, 8, 28),
    );

    expect(secondDraft.normalSubjectTasks.single.subjectId, 'physics');
  });
}
