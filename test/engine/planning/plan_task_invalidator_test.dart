import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/study_route.dart';
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

  group('evaluateTaskInvalidation', () {
    test('keeps task valid when refreshed candidate still supports it', () {
      const task = StudyTask(
        topicId: 'trigonometri',
        type: StudyTaskType.repair,
        sourceTopicId: 'trigonometri',
      );

      final result = evaluateTaskInvalidation(
        task: task,
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

      expect(result.isInvalidated, isFalse);
      expect(
        result.reason,
        PlanTaskInvalidationReason.stillSupported,
      );
    });

    test('invalidates task when candidate no longer exists', () {
      const task = StudyTask(
        topicId: 'turev',
        type: StudyTaskType.repair,
        sourceTopicId: 'turev',
      );

      final result = evaluateTaskInvalidation(
        task: task,
        refreshedCandidates: const [],
      );

      expect(result.isInvalidated, isTrue);
      expect(
        result.reason,
        PlanTaskInvalidationReason.candidateNoLongerExists,
      );
    });

    test(
      'invalidates task when topic remains candidate but original source disappears',
      () {
        const task = StudyTask(
          topicId: 'integral',
          type: StudyTaskType.repair,
          sourceTopicId: 'integral',
        );

        final result = evaluateTaskInvalidation(
          task: task,
          refreshedCandidates: [
            candidate(
              topicId: 'integral',
              primarySource: CandidateSource.measurement,
              sources: {
                CandidateSource.measurement,
              },
            ),
          ],
        );

        expect(result.isInvalidated, isTrue);
        expect(
          result.reason,
          PlanTaskInvalidationReason.sourceNoLongerSupportsTask,
        );
      },
    );

    test('invalidates bridge when target no longer requires bridge', () {
      const task = StudyTask(
        topicId: 'fonksiyonlar',
        type: StudyTaskType.bridge,
        sourceTopicId: 'limit_ve_sureklilik',
      );

      final result = evaluateTaskInvalidation(
        task: task,
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

      expect(result.isInvalidated, isTrue);
      expect(
        result.reason,
        PlanTaskInvalidationReason.bridgeNoLongerRequired,
      );
    });

    test('invalidates bridge when selected bridge topic changes', () {
      const task = StudyTask(
        topicId: 'fonksiyonlar',
        type: StudyTaskType.bridge,
        sourceTopicId: 'limit_ve_sureklilik',
      );

      final result = evaluateTaskInvalidation(
        task: task,
        refreshedCandidates: [
          candidate(
            topicId: 'limit_ve_sureklilik',
            primarySource: CandidateSource.progress,
            sources: {
              CandidateSource.progress,
            },
            requiresBridge: true,
            bridgeTopicId: 'denklem_cozme',
          ),
        ],
      );

      expect(result.isInvalidated, isTrue);
      expect(
        result.reason,
        PlanTaskInvalidationReason.bridgeChanged,
      );
    });

    test('keeps bridge valid when same bridge is still required', () {
      const task = StudyTask(
        topicId: 'fonksiyonlar',
        type: StudyTaskType.bridge,
        sourceTopicId: 'limit_ve_sureklilik',
      );

      final result = evaluateTaskInvalidation(
        task: task,
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

      expect(result.isInvalidated, isFalse);
      expect(
        result.reason,
        PlanTaskInvalidationReason.stillSupported,
      );
    });
  });
}