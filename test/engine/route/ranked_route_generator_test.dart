import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/selected_mode.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/topic_exam_profile.dart';
import 'package:rota_app/engine/ranking/candidate_ranker.dart';
import 'package:rota_app/engine/route/ranked_route_generator.dart';
import 'package:rota_app/engine/route/route_selector.dart';

void main() {
  const rankingConfig = RankingConfig(
    signalStrengthWeight: 0.50,
    examImportanceWeight: 0.30,
    sourceDiversityWeight: 0.20,
    bridgeCostWeight: 0.10,
  );

  const routeSelectionConfig = RouteSelectionConfig(maxTasks: 4);

  group('generateRankedRoute', () {
    test('ranking order is reflected in route task order', () {
      const candidates = [
        StudyCandidate(
          topicId: 'low_priority',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.30,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'high_priority',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.90,
            ),
          ],
        ),
      ];

      final route = generateRankedRoute(
        const RankedRouteGenerationInput(
          subjectId: 'mathematics',
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          selectedMode: SelectedMode.balanced,
        ),
      );

      expect(route.tasks, hasLength(2));
      expect(route.tasks[0].topicId, 'high_priority');
      expect(route.tasks[1].topicId, 'low_priority');
    });

    test('exam importance can change route order', () {
      const candidates = [
        StudyCandidate(
          topicId: 'topic_a',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.60,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'topic_b',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.60,
            ),
          ],
        ),
      ];

      final route = generateRankedRoute(
        const RankedRouteGenerationInput(
          subjectId: 'mathematics',
          candidates: candidates,
          examProfilesByTopicId: {
            'topic_a': TopicExamProfile(
              topicId: 'topic_a',
              examImportance: 0.20,
            ),
            'topic_b': TopicExamProfile(
              topicId: 'topic_b',
              examImportance: 0.90,
            ),
          },
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          selectedMode: SelectedMode.balanced,
        ),
      );

      expect(route.tasks[0].topicId, 'topic_b');
      expect(route.tasks[1].topicId, 'topic_a');
    });

    test('bridge cost can lower candidate position', () {
      const candidates = [
        StudyCandidate(
          topicId: 'bridge_target',
          primarySource: CandidateSource.progress,
          sources: {CandidateSource.progress},
          requiresBridge: true,
          bridgeTopicId: 'bridge_topic',
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.70,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'direct_target',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.70,
            ),
          ],
        ),
      ];

      final route = generateRankedRoute(
        const RankedRouteGenerationInput(
          subjectId: 'mathematics',
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          selectedMode: SelectedMode.balanced,
        ),
      );

      expect(route.tasks.first.topicId, 'direct_target');
    });

    test('route selection applies four-task ceiling after ranking', () {
      const candidates = [
        StudyCandidate(
          topicId: 'a',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.90,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'b',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.80,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'c',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.70,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'd',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.60,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'e',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.50,
            ),
          ],
        ),
      ];

      final route = generateRankedRoute(
        const RankedRouteGenerationInput(
          subjectId: 'mathematics',
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          selectedMode: SelectedMode.balanced,
        ),
      );

      expect(route.tasks, hasLength(4));

      expect(route.tasks.map((task) => task.topicId), ['a', 'b', 'c', 'd']);
    });

    test('bridge and target remain together after ranking and selection', () {
      const candidates = [
        StudyCandidate(
          topicId: 'bridge_target',
          primarySource: CandidateSource.progress,
          sources: {CandidateSource.progress},
          requiresBridge: true,
          bridgeTopicId: 'bridge_topic',
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.95,
            ),
          ],
        ),
        StudyCandidate(
          topicId: 'other_topic',
          primarySource: CandidateSource.repair,
          sources: {CandidateSource.repair},
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.40,
            ),
          ],
        ),
      ];

      final route = generateRankedRoute(
        const RankedRouteGenerationInput(
          subjectId: 'mathematics',
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: RouteSelectionConfig(maxTasks: 2),
          selectedMode: SelectedMode.balanced,
        ),
      );

      expect(route.tasks, hasLength(2));
      expect(route.tasks[0].topicId, 'bridge_topic');
      expect(route.tasks[1].topicId, 'bridge_target');
    });

    test('same input produces same ranked route', () {
      const input = RankedRouteGenerationInput(
        subjectId: 'mathematics',
        candidates: [
          StudyCandidate(
            topicId: 'beta',
            primarySource: CandidateSource.repair,
            sources: {CandidateSource.repair},
            requiresBridge: false,
            bridgeTopicId: null,
            signals: [
              CandidateSignal(
                source: CandidateSource.repair,
                reason: CandidateReason.lowMastery,
                strength: 0.60,
              ),
            ],
          ),
          StudyCandidate(
            topicId: 'alpha',
            primarySource: CandidateSource.repair,
            sources: {CandidateSource.repair},
            requiresBridge: false,
            bridgeTopicId: null,
            signals: [
              CandidateSignal(
                source: CandidateSource.repair,
                reason: CandidateReason.lowMastery,
                strength: 0.60,
              ),
            ],
          ),
        ],
        examProfilesByTopicId: {},
        rankingConfig: rankingConfig,
        routeSelectionConfig: routeSelectionConfig,
        selectedMode: SelectedMode.balanced,
      );

      final first = generateRankedRoute(input);
      final second = generateRankedRoute(input);

      expect(first.tasks.length, second.tasks.length);

      for (var i = 0; i < first.tasks.length; i++) {
        expect(first.tasks[i].topicId, second.tasks[i].topicId);
        expect(first.tasks[i].type, second.tasks[i].type);
      }
    });
  });
}
