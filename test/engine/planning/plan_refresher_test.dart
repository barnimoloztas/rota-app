import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/plan_task_state.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/engine/planning/plan_refresh_selector.dart';
import 'package:rota_app/engine/planning/plan_refresher.dart';

void main() {
  PlanTaskState state(
    String topicId, {
    PlanTaskOwner owner = PlanTaskOwner.coach,
    bool touched = false,
  }) {
    return PlanTaskState(
      topicId: topicId,
      owner: owner,
      wasTouchedByStudent: touched,
    );
  }

  StudyCandidate candidate({
    required String topicId,
    required CandidateSource source,
  }) {
    return StudyCandidate(
      topicId: topicId,
      primarySource: source,
      sources: {
        source,
      },
      requiresBridge: false,
      bridgeTopicId: null,
    );
  }

  StudyTask task({
    required String topicId,
    required StudyTaskType type,
  }) {
    return StudyTask(
      topicId: topicId,
      type: type,
      sourceTopicId: topicId,
    );
  }

  group('refreshPlan', () {
    test('keeps protected student task even if candidate disappears', () {
      final result = refreshPlan(
        PlanRefreshInput(
          previousTasks: [
            task(
              topicId: 'fonksiyonlar',
              type: StudyTaskType.repair,
            ),
          ],
          previousTaskStates: [
            state(
              'fonksiyonlar',
              owner: PlanTaskOwner.student,
            ),
          ],
          refreshedCandidates: const [],
          rankedRefreshedTasks: [
            task(
              topicId: 'turev',
              type: StudyTaskType.repair,
            ),
          ],
          lifecycle: PlanLifecycle.draftStudentModified,
          selectionConfig: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        ),
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
    });

    test('replaces invalid untouched coach task with ranked replacement', () {
      final result = refreshPlan(
        PlanRefreshInput(
          previousTasks: [
            task(
              topicId: 'integral',
              type: StudyTaskType.repair,
            ),
          ],
          previousTaskStates: [
            state('integral'),
          ],
          refreshedCandidates: [
            candidate(
              topicId: 'turev',
              source: CandidateSource.repair,
            ),
          ],
          rankedRefreshedTasks: [
            task(
              topicId: 'turev',
              type: StudyTaskType.repair,
            ),
          ],
          lifecycle: PlanLifecycle.draftUntouched,
          selectionConfig: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        ),
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'turev');
    });

    test('drops invalid task when no replacement exists', () {
      final result = refreshPlan(
        PlanRefreshInput(
          previousTasks: [
            task(
              topicId: 'integral',
              type: StudyTaskType.repair,
            ),
          ],
          previousTaskStates: [
            state('integral'),
          ],
          refreshedCandidates: const [],
          rankedRefreshedTasks: const [],
          lifecycle: PlanLifecycle.draftUntouched,
          selectionConfig: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        ),
      );

      expect(result, isEmpty);
    });

    test('active plan remains unchanged', () {
      final previousTasks = [
        task(
          topicId: 'fonksiyonlar',
          type: StudyTaskType.progress,
        ),
        task(
          topicId: 'trigonometri',
          type: StudyTaskType.repair,
        ),
      ];

      final result = refreshPlan(
        PlanRefreshInput(
          previousTasks: previousTasks,
          previousTaskStates: [
            state('fonksiyonlar'),
            state('trigonometri'),
          ],
          refreshedCandidates: const [],
          rankedRefreshedTasks: [
            task(
              topicId: 'turev',
              type: StudyTaskType.measurement,
            ),
          ],
          lifecycle: PlanLifecycle.active,
          selectionConfig: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        ),
      );

      expect(result, hasLength(2));
      expect(result[0].topicId, 'fonksiyonlar');
      expect(result[1].topicId, 'trigonometri');
    });

    test('student-modified draft does not grow beyond previous count', () {
      final result = refreshPlan(
        PlanRefreshInput(
          previousTasks: [
            task(
              topicId: 'a',
              type: StudyTaskType.repair,
            ),
            task(
              topicId: 'b',
              type: StudyTaskType.repair,
            ),
          ],
          previousTaskStates: [
            state('a'),
            state('b'),
          ],
          refreshedCandidates: [
            candidate(
              topicId: 'c',
              source: CandidateSource.repair,
            ),
            candidate(
              topicId: 'd',
              source: CandidateSource.repair,
            ),
            candidate(
              topicId: 'e',
              source: CandidateSource.repair,
            ),
          ],
          rankedRefreshedTasks: [
            task(
              topicId: 'c',
              type: StudyTaskType.repair,
            ),
            task(
              topicId: 'd',
              type: StudyTaskType.repair,
            ),
            task(
              topicId: 'e',
              type: StudyTaskType.repair,
            ),
          ],
          lifecycle: PlanLifecycle.draftStudentModified,
          selectionConfig: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        ),
      );

      expect(result.length, lessThanOrEqualTo(2));
    });

    test('untouched draft still respects max four tasks', () {
      final result = refreshPlan(
        PlanRefreshInput(
          previousTasks: const [],
          previousTaskStates: const [],
          refreshedCandidates: [
            candidate(
              topicId: 'a',
              source: CandidateSource.repair,
            ),
            candidate(
              topicId: 'b',
              source: CandidateSource.repair,
            ),
            candidate(
              topicId: 'c',
              source: CandidateSource.repair,
            ),
            candidate(
              topicId: 'd',
              source: CandidateSource.repair,
            ),
            candidate(
              topicId: 'e',
              source: CandidateSource.repair,
            ),
          ],
          rankedRefreshedTasks: [
            task(
              topicId: 'a',
              type: StudyTaskType.repair,
            ),
            task(
              topicId: 'b',
              type: StudyTaskType.repair,
            ),
            task(
              topicId: 'c',
              type: StudyTaskType.repair,
            ),
            task(
              topicId: 'd',
              type: StudyTaskType.repair,
            ),
            task(
              topicId: 'e',
              type: StudyTaskType.repair,
            ),
          ],
          lifecycle: PlanLifecycle.draftUntouched,
          selectionConfig: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        ),
      );

      expect(result.length, lessThanOrEqualTo(4));
    });
  });
}