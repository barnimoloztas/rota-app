import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/selected_mode.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/engine/route/route_builder.dart';

void main() {
  group('buildRoute', () {
    test('converts progress candidate into progress task', () {
      const candidate = StudyCandidate(
        topicId: 'fonksiyonlar',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final route = buildRoute(
        candidates: const [candidate],
        selectedMode: SelectedMode.balanced,
      );

      expect(route.tasks, hasLength(1));
      expect(route.tasks.first.topicId, 'fonksiyonlar');
      expect(route.tasks.first.type, StudyTaskType.progress);
      expect(route.tasks.first.questionTarget, isNull);
    });

    test('assigns 30 questions to practice in relaxed mode', () {
      const candidate = StudyCandidate(
        topicId: 'problemler',
        primarySource: CandidateSource.practice,
        sources: {
          CandidateSource.practice,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final route = buildRoute(
        candidates: const [candidate],
        selectedMode: SelectedMode.relaxed,
      );

      expect(route.tasks.single.type, StudyTaskType.practice);
      expect(route.tasks.single.questionTarget, 30);
    });

    test('assigns 40 questions to practice in balanced mode', () {
      const candidate = StudyCandidate(
        topicId: 'problemler',
        primarySource: CandidateSource.practice,
        sources: {
          CandidateSource.practice,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final route = buildRoute(
        candidates: const [candidate],
        selectedMode: SelectedMode.balanced,
      );

      expect(route.tasks.single.questionTarget, 40);
    });

    test('assigns 60 questions to practice in strict mode', () {
      const candidate = StudyCandidate(
        topicId: 'problemler',
        primarySource: CandidateSource.practice,
        sources: {
          CandidateSource.practice,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final route = buildRoute(
        candidates: const [candidate],
        selectedMode: SelectedMode.strict,
      );

      expect(route.tasks.single.questionTarget, 60);
    });

    test('converts all candidate source types into matching task types', () {
      const candidates = [
        StudyCandidate(
          topicId: 'fonksiyonlar',
          primarySource: CandidateSource.progress,
          sources: {
            CandidateSource.progress,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
        StudyCandidate(
          topicId: 'problemler',
          primarySource: CandidateSource.practice,
          sources: {
            CandidateSource.practice,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
        StudyCandidate(
          topicId: 'trigonometri',
          primarySource: CandidateSource.repair,
          sources: {
            CandidateSource.repair,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
        StudyCandidate(
          topicId: 'integral',
          primarySource: CandidateSource.measurement,
          sources: {
            CandidateSource.measurement,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
      ];

      final route = buildRoute(
        candidates: candidates,
        selectedMode: SelectedMode.balanced,
      );

      expect(route.tasks, hasLength(4));

      expect(route.tasks[0].type, StudyTaskType.progress);
      expect(route.tasks[0].questionTarget, isNull);

      expect(route.tasks[1].type, StudyTaskType.practice);
      expect(route.tasks[1].questionTarget, 40);

      expect(route.tasks[2].type, StudyTaskType.repair);
      expect(route.tasks[2].questionTarget, isNull);

      expect(route.tasks[3].type, StudyTaskType.measurement);
      expect(route.tasks[3].questionTarget, isNull);
    });

    test('places bridge task before its target task', () {
      const candidate = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: true,
        bridgeTopicId: 'fonksiyonlar',
      );

      final route = buildRoute(
        candidates: const [candidate],
        selectedMode: SelectedMode.balanced,
      );

      expect(route.tasks, hasLength(2));

      expect(route.tasks[0].topicId, 'fonksiyonlar');
      expect(route.tasks[0].type, StudyTaskType.bridge);
      expect(route.tasks[0].questionTarget, isNull);
      expect(
        route.tasks[0].sourceTopicId,
        'limit_ve_sureklilik',
      );

      expect(route.tasks[1].topicId, 'limit_ve_sureklilik');
      expect(route.tasks[1].type, StudyTaskType.progress);
      expect(route.tasks[1].questionTarget, isNull);
    });

    test('deduplicates shared bridge topic across multiple targets', () {
      const candidates = [
        StudyCandidate(
          topicId: 'target_a',
          primarySource: CandidateSource.progress,
          sources: {
            CandidateSource.progress,
          },
          requiresBridge: true,
          bridgeTopicId: 'fonksiyonlar',
        ),
        StudyCandidate(
          topicId: 'target_b',
          primarySource: CandidateSource.progress,
          sources: {
            CandidateSource.progress,
          },
          requiresBridge: true,
          bridgeTopicId: 'fonksiyonlar',
        ),
      ];

      final route = buildRoute(
        candidates: candidates,
        selectedMode: SelectedMode.balanced,
      );

      expect(route.tasks, hasLength(3));

      final bridgeTasks = route.tasks
          .where(
            (task) =>
                task.type == StudyTaskType.bridge &&
                task.topicId == 'fonksiyonlar',
          )
          .toList();

      expect(bridgeTasks, hasLength(1));
    });

    test('preserves candidate order deterministically', () {
      const candidates = [
        StudyCandidate(
          topicId: 'fonksiyonlar',
          primarySource: CandidateSource.progress,
          sources: {
            CandidateSource.progress,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
        StudyCandidate(
          topicId: 'trigonometri',
          primarySource: CandidateSource.repair,
          sources: {
            CandidateSource.repair,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
      ];

      final first = buildRoute(
        candidates: candidates,
        selectedMode: SelectedMode.balanced,
      );

      final second = buildRoute(
        candidates: candidates,
        selectedMode: SelectedMode.balanced,
      );

      expect(first.tasks.length, second.tasks.length);

      for (var i = 0; i < first.tasks.length; i++) {
        expect(first.tasks[i].topicId, second.tasks[i].topicId);
        expect(first.tasks[i].type, second.tasks[i].type);
        expect(
          first.tasks[i].sourceTopicId,
          second.tasks[i].sourceTopicId,
        );
        expect(
          first.tasks[i].questionTarget,
          second.tasks[i].questionTarget,
        );
      }
    });

    test('builds an empty route from empty candidates', () {
      final route = buildRoute(
        candidates: const [],
        selectedMode: SelectedMode.balanced,
      );

      expect(route.tasks, isEmpty);
    });
  });
}