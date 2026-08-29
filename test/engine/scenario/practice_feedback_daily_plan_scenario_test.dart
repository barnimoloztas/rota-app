import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/domain/selected_mode.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_study_route.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/candidate/practice_candidate_generator.dart';
import 'package:rota_app/engine/planning/daily_plan_activation.dart';
import 'package:rota_app/engine/planning/daily_plan_practice_completion.dart';
import 'package:rota_app/engine/planning/global_study_route_composer.dart';
import 'package:rota_app/engine/planning/subject_plan_task_mapper.dart';
import 'package:rota_app/engine/planning/untouched_daily_plan_composer.dart';
import 'package:rota_app/engine/route/route_builder.dart';
import 'package:rota_app/engine/route/route_selector.dart';
import 'package:rota_app/engine/signal/practice_signal_generator.dart';

void main() {
  SubjectStudyRoute practiceRoute({
    required TopicLearningLifecycle lifecycle,
    required DateTime evaluatedAt,
  }) {
    final signal = generatePracticeSignals(
      lifecycles: [lifecycle],
      evaluatedAt: evaluatedAt,
    ).single;
    final candidate = generatePracticeCandidate(signal: signal);

    return SubjectStudyRoute(
      subjectId: 'mathematics',
      route: buildRoute(
        candidates: [candidate],
        selectedMode: SelectedMode.balanced,
      ),
    );
  }

  SubjectStudyRoute standardPhysicsRoute() {
    return const SubjectStudyRoute(
      subjectId: 'physics',
      route: StudyRoute(
        tasks: [
          StudyTask(
            topicId: 'vectors',
            type: StudyTaskType.progress,
            sourceTopicId: 'vectors',
          ),
        ],
      ),
    );
  }

  test(
    'active P1 completion produces an urgent P2 without changing allocation',
    () {
      final firstDay = DateTime.utc(2026, 8, 29);
      final secondDay = DateTime.utc(2026, 8, 30);
      var lifecycle = TopicLearningLifecycle(
        topicId: 'functions',
        progressCompletedAt: firstDay,
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
      );

      final firstSegments = composeGlobalStudyRoute(
        subjectRoutes: [
          practiceRoute(lifecycle: lifecycle, evaluatedAt: firstDay),
          standardPhysicsRoute(),
        ],
        targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {},
        selectionConfig: const RouteSelectionConfig(maxTasks: 1),
      );
      final firstDraft = composeUntouchedDailyPlan(
        rankedNormalTasks: subjectPlanTasksFromRoutes(firstSegments),
        reinforcementCandidates: const [],
        evaluatedAt: firstDay,
      );
      final firstTask = firstDraft.normalSubjectTasks.single;

      expect(firstTask.subjectId, 'mathematics');
      expect(firstTask.task.type, StudyTaskType.practice);
      expect(firstTask.task.priority, StudyTaskPriority.urgent);

      final activation = activateDailyPlan(
        lifecycle: PlanLifecycle.draftUntouched,
        dailyPlan: firstDraft,
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {},
      );

      expect(activation.lifecycle, PlanLifecycle.active);
      expect(activation.allocatedSlotsBySubject, {'mathematics': 1});

      final completion = completeDailyPlanPractice(
        planLifecycle: activation.lifecycle,
        dailyPlan: firstDraft,
        academicTaskIndex: 0,
        completedAcademicTaskIndexes: const {},
        topicLifecycle: lifecycle,
        completedAt: firstDay,
        actualQuestionCount: 40,
        correctCount: 31,
        wrongCount: 7,
        blankCount: 2,
      );
      lifecycle = completion.topicLifecycle;

      expect(completion.didComplete, isTrue);
      expect(completion.completionRecord!.topicId, 'functions');
      expect(completion.completionRecord!.completedAt, firstDay);
      expect(completion.completionRecord!.actualQuestionCount, 40);
      expect(completion.completionRecord!.correctCount, 31);
      expect(completion.completionRecord!.wrongCount, 7);
      expect(completion.completionRecord!.blankCount, 2);
      expect(completion.completedAcademicTaskIndexes, {0});
      expect(lifecycle.completedInitialPracticeCount, 1);
      expect(lifecycle.firstPracticeCompletedAt, firstDay);
      expect(activation.allocatedSlotsBySubject, {'mathematics': 1});
      expect(
        generatePracticeSignals(lifecycles: [lifecycle], evaluatedAt: firstDay),
        isEmpty,
      );

      final secondSegments = composeGlobalStudyRoute(
        subjectRoutes: [
          practiceRoute(lifecycle: lifecycle, evaluatedAt: secondDay),
          standardPhysicsRoute(),
        ],
        targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
        planPhase: PreparationPhase.early,
        allocationPhase: activation.allocationPhase,
        allocatedSlotsBySubject: activation.allocatedSlotsBySubject,
        selectionConfig: const RouteSelectionConfig(maxTasks: 1),
      );
      final secondDraft = composeUntouchedDailyPlan(
        rankedNormalTasks: subjectPlanTasksFromRoutes(secondSegments),
        reinforcementCandidates: const [],
        evaluatedAt: secondDay,
      );
      final secondTask = secondDraft.normalSubjectTasks.single;

      expect(secondTask.subjectId, 'mathematics');
      expect(secondTask.task.type, StudyTaskType.practice);
      expect(secondTask.task.priority, StudyTaskPriority.urgent);
      expect(activation.allocatedSlotsBySubject, {'mathematics': 1});
    },
  );
}
