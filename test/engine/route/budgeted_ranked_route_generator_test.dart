import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_study_budget.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/engine/ranking/candidate_ranker.dart';
import 'package:rota_app/engine/route/budgeted_ranked_route_generator.dart';
import 'package:rota_app/engine/route/route_selector.dart';
import 'package:rota_app/engine/route/study_task_effort_policy.dart';

void main() {
  const rankingConfig = RankingConfig(
    signalStrengthWeight: 0.50,
    examImportanceWeight: 0.30,
    sourceDiversityWeight: 0.20,
    bridgeCostWeight: 0.10,
  );

  const routeSelectionConfig = RouteSelectionConfig(
    maxTasks: 4,
  );

  const effortPolicyConfig = StudyTaskEffortPolicyConfig(
    minutesByTaskType: {
      StudyTaskType.progress: 40,
      StudyTaskType.repair: 30,
      StudyTaskType.reinforcement: 20,
      StudyTaskType.measurement: 15,
      StudyTaskType.bridge: 10,
    },
  );

  group('generateBudgetedRankedRoute', () {
    test('ranking order is preserved while budget removes oversized tasks', () {
      const candidates = [
        StudyCandidate(
          topicId: 'high_priority',
          primarySource: CandidateSource.repair,
          sources: {
            CandidateSource.repair,
          },
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
          topicId: 'medium_priority',
          primarySource: CandidateSource.progress,
          sources: {
            CandidateSource.progress,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
        StudyCandidate(
          topicId: 'lower_priority',
          primarySource: CandidateSource.measurement,
          sources: {
            CandidateSource.measurement,
          },
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.measurement,
              reason: CandidateReason.lowConfidence,
              strength: 0.40,
            ),
          ],
        ),
      ];

      final route = generateBudgetedRankedRoute(
        const BudgetedRankedRouteGenerationInput(
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          studyBudget: DailyStudyBudget(
            availableMinutes: 45,
          ),
          effortPolicyConfig: effortPolicyConfig,
        ),
      );

      expect(route.tasks, hasLength(2));

      expect(
        route.tasks.map((task) => task.topicId),
        ['high_priority', 'lower_priority'],
      );
    });

    test('daily budget can reduce ranked route below max task ceiling', () {
      const candidates = [
        StudyCandidate(
          topicId: 'a',
          primarySource: CandidateSource.repair,
          sources: {
            CandidateSource.repair,
          },
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
          sources: {
            CandidateSource.repair,
          },
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
          sources: {
            CandidateSource.repair,
          },
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

      final route = generateBudgetedRankedRoute(
        const BudgetedRankedRouteGenerationInput(
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          studyBudget: DailyStudyBudget(
            availableMinutes: 60,
          ),
          effortPolicyConfig: effortPolicyConfig,
        ),
      );

      expect(route.tasks, hasLength(2));
      expect(
        route.tasks.map((task) => task.topicId),
        ['a', 'b'],
      );
    });

    test('zero study budget produces empty final route', () {
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
      ];

      final route = generateBudgetedRankedRoute(
        const BudgetedRankedRouteGenerationInput(
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          studyBudget: DailyStudyBudget(
            availableMinutes: 0,
          ),
          effortPolicyConfig: effortPolicyConfig,
        ),
      );

      expect(route.tasks, isEmpty);
    });

    test('bridge and target survive only when the pair fits budget', () {
      const candidates = [
        StudyCandidate(
          topicId: 'limit_ve_sureklilik',
          primarySource: CandidateSource.progress,
          sources: {
            CandidateSource.progress,
          },
          requiresBridge: true,
          bridgeTopicId: 'fonksiyonlar',
        ),
      ];

      final fits = generateBudgetedRankedRoute(
        const BudgetedRankedRouteGenerationInput(
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          studyBudget: DailyStudyBudget(
            availableMinutes: 50,
          ),
          effortPolicyConfig: effortPolicyConfig,
        ),
      );

      expect(fits.tasks, hasLength(2));
      expect(fits.tasks[0].topicId, 'fonksiyonlar');
      expect(
        fits.tasks[1].topicId,
        'limit_ve_sureklilik',
      );

      final doesNotFit = generateBudgetedRankedRoute(
        const BudgetedRankedRouteGenerationInput(
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          studyBudget: DailyStudyBudget(
            availableMinutes: 45,
          ),
          effortPolicyConfig: effortPolicyConfig,
        ),
      );

      expect(doesNotFit.tasks, isEmpty);
    });

    test('missing effort configuration prevents zero-cost scheduling', () {
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
      ];

      final route = generateBudgetedRankedRoute(
        const BudgetedRankedRouteGenerationInput(
          candidates: candidates,
          examProfilesByTopicId: {},
          rankingConfig: rankingConfig,
          routeSelectionConfig: routeSelectionConfig,
          studyBudget: DailyStudyBudget(
            availableMinutes: 120,
          ),
          effortPolicyConfig: StudyTaskEffortPolicyConfig(
            minutesByTaskType: {},
          ),
        ),
      );

      expect(route.tasks, isEmpty);
    });

    test('same input produces same final budgeted route', () {
      const input = BudgetedRankedRouteGenerationInput(
        candidates: [
          StudyCandidate(
            topicId: 'beta',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
            },
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
            sources: {
              CandidateSource.repair,
            },
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
        studyBudget: DailyStudyBudget(
          availableMinutes: 60,
        ),
        effortPolicyConfig: effortPolicyConfig,
      );

      final first = generateBudgetedRankedRoute(input);
      final second = generateBudgetedRankedRoute(input);

      expect(first.tasks.length, second.tasks.length);

      for (var i = 0; i < first.tasks.length; i++) {
        expect(first.tasks[i].topicId, second.tasks[i].topicId);
        expect(first.tasks[i].type, second.tasks[i].type);
      }
    });
  });
}