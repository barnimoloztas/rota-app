import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_task_state.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/engine/planning/plan_refresh_evaluator.dart';
import 'package:rota_app/engine/planning/plan_task_invalidator.dart';

void main() {
  StudyCandidate candidate({
    required String topicId,
    required CandidateSource primarySource,
    required Set<CandidateSource> sources,
    bool requiresBridge = false,
    String? bridgeTopicId,
  }) {
    return StudyCandidate(
      topicId: topicId,
      primarySource: primarySource,
      sources: sources,
      requiresBridge: requiresBridge,
      bridgeTopicId: bridgeTopicId,
    );
  }

  group('evaluatePlanRefresh', () {
    test(
      'keeps student-owned task even when refreshed state invalidates it',
      () {
        const taskState = PlanTaskState(
          topicId: 'fonksiyonlar',
          owner: PlanTaskOwner.student,
          wasTouchedByStudent: false,
        );

        const studyTask = StudyTask(
          topicId: 'fonksiyonlar',
          type: StudyTaskType.repair,
          sourceTopicId: 'fonksiyonlar',
        );

        final result = evaluatePlanRefresh(
          task: taskState,
          studyTask: studyTask,
          refreshedCandidates: const [],
        );

        expect(result.decision, PlanRefreshDecision.keep);
        expect(result.invalidation.isInvalidated, isTrue);
        expect(
          result.invalidation.reason,
          PlanTaskInvalidationReason.candidateNoLongerExists,
        );
      },
    );

    test(
      'keeps coach-owned task after student touched it even when invalidated',
      () {
        const taskState = PlanTaskState(
          topicId: 'turev',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: true,
        );

        const studyTask = StudyTask(
          topicId: 'turev',
          type: StudyTaskType.repair,
          sourceTopicId: 'turev',
        );

        final result = evaluatePlanRefresh(
          task: taskState,
          studyTask: studyTask,
          refreshedCandidates: const [],
        );

        expect(result.decision, PlanRefreshDecision.keep);
        expect(result.invalidation.isInvalidated, isTrue);
      },
    );

    test(
      'replaces untouched coach-owned task when candidate disappears',
      () {
        const taskState = PlanTaskState(
          topicId: 'integral',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: false,
        );

        const studyTask = StudyTask(
          topicId: 'integral',
          type: StudyTaskType.repair,
          sourceTopicId: 'integral',
        );

        final result = evaluatePlanRefresh(
          task: taskState,
          studyTask: studyTask,
          refreshedCandidates: const [],
        );

        expect(result.decision, PlanRefreshDecision.replace);
        expect(result.invalidation.isInvalidated, isTrue);
        expect(
          result.invalidation.reason,
          PlanTaskInvalidationReason.candidateNoLongerExists,
        );
      },
    );

    test(
      'keeps untouched coach-owned task when refreshed candidate still supports same source',
      () {
        const taskState = PlanTaskState(
          topicId: 'trigonometri',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: false,
        );

        const studyTask = StudyTask(
          topicId: 'trigonometri',
          type: StudyTaskType.repair,
          sourceTopicId: 'trigonometri',
        );

        final result = evaluatePlanRefresh(
          task: taskState,
          studyTask: studyTask,
          refreshedCandidates: [
            candidate(
              topicId: 'trigonometri',
              primarySource: CandidateSource.repair,
              sources: {
                CandidateSource.repair,
                CandidateSource.measurement,
              },
            ),
          ],
        );

        expect(result.decision, PlanRefreshDecision.keep);
        expect(result.invalidation.isInvalidated, isFalse);
        expect(
          result.invalidation.reason,
          PlanTaskInvalidationReason.stillSupported,
        );
      },
    );

    test(
      'replaces untouched coach-owned task when original source disappears',
      () {
        const taskState = PlanTaskState(
          topicId: 'limit_ve_sureklilik',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: false,
        );

        const studyTask = StudyTask(
          topicId: 'limit_ve_sureklilik',
          type: StudyTaskType.repair,
          sourceTopicId: 'limit_ve_sureklilik',
        );

        final result = evaluatePlanRefresh(
          task: taskState,
          studyTask: studyTask,
          refreshedCandidates: [
            candidate(
              topicId: 'limit_ve_sureklilik',
              primarySource: CandidateSource.measurement,
              sources: {
                CandidateSource.measurement,
              },
            ),
          ],
        );

        expect(result.decision, PlanRefreshDecision.replace);
        expect(result.invalidation.isInvalidated, isTrue);
        expect(
          result.invalidation.reason,
          PlanTaskInvalidationReason.sourceNoLongerSupportsTask,
        );
      },
    );

    test(
      'replaces untouched coach-owned bridge when bridge is no longer required',
      () {
        const taskState = PlanTaskState(
          topicId: 'fonksiyonlar',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: false,
        );

        const studyTask = StudyTask(
          topicId: 'fonksiyonlar',
          type: StudyTaskType.bridge,
          sourceTopicId: 'limit_ve_sureklilik',
        );

        final result = evaluatePlanRefresh(
          task: taskState,
          studyTask: studyTask,
          refreshedCandidates: [
            candidate(
              topicId: 'limit_ve_sureklilik',
              primarySource: CandidateSource.progress,
              sources: {
                CandidateSource.progress,
              },
              requiresBridge: false,
              bridgeTopicId: null,
            ),
          ],
        );

        expect(result.decision, PlanRefreshDecision.replace);
        expect(result.invalidation.isInvalidated, isTrue);
        expect(
          result.invalidation.reason,
          PlanTaskInvalidationReason.bridgeNoLongerRequired,
        );
      },
    );

    test(
      'keeps untouched coach-owned bridge when same bridge remains required',
      () {
        const taskState = PlanTaskState(
          topicId: 'fonksiyonlar',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: false,
        );

        const studyTask = StudyTask(
          topicId: 'fonksiyonlar',
          type: StudyTaskType.bridge,
          sourceTopicId: 'limit_ve_sureklilik',
        );

        final result = evaluatePlanRefresh(
          task: taskState,
          studyTask: studyTask,
          refreshedCandidates: [
            candidate(
              topicId: 'limit_ve_sureklilik',
              primarySource: CandidateSource.progress,
              sources: {
                CandidateSource.progress,
              },
              requiresBridge: true,
              bridgeTopicId: 'fonksiyonlar',
            ),
          ],
        );

        expect(result.decision, PlanRefreshDecision.keep);
        expect(result.invalidation.isInvalidated, isFalse);
      },
    );
  });
}