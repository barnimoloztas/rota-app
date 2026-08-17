import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/candidate_evaluation.dart';
import 'package:rota_app/domain/planning_mode.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/ranking/candidate_ranker.dart';

void main() {
  const baseConfig = RankingConfig(
    signalStrengthWeight: 0.50,
    examImportanceWeight: 0.30,
    sourceDiversityWeight: 0.20,
    bridgeCostWeight: 0.10,
  );

  const modeAwareConfig = RankingConfig(
    signalStrengthWeight: 0.50,
    examImportanceWeight: 0.30,
    sourceDiversityWeight: 0.20,
    bridgeCostWeight: 0.10,
    modeEmphasisBonus: 0.20,
    modeDeemphasisPenalty: 0.15,
    bridgeProgressModePenalty: 0.15,
  );

  CandidateEvaluation evaluation({
    required String topicId,
    required CandidateSource primarySource,
    required Set<CandidateSource> sources,
    required double signalStrength,
    required double examImportance,
    required bool hasBridge,
  }) {
    return CandidateEvaluation(
      topicId: topicId,
      candidate: StudyCandidate(
        topicId: topicId,
        primarySource: primarySource,
        sources: sources,
        requiresBridge: hasBridge,
        bridgeTopicId: hasBridge ? 'bridge_topic' : null,
      ),
      signalStrength: signalStrength,
      sourceCount: sources.length,
      hasBridge: hasBridge,
      examImportance: examImportance,
    );
  }

  group('rankCandidates - base ranking', () {
    test(
      'ranks higher signal strength first when other inputs are equal',
      () {
        final ranked = rankCandidates(
          evaluations: [
            evaluation(
              topicId: 'a',
              primarySource: CandidateSource.repair,
              sources: {
                CandidateSource.repair,
              },
              signalStrength: 0.80,
              examImportance: 0.50,
              hasBridge: false,
            ),
            evaluation(
              topicId: 'b',
              primarySource: CandidateSource.repair,
              sources: {
                CandidateSource.repair,
              },
              signalStrength: 0.40,
              examImportance: 0.50,
              hasBridge: false,
            ),
          ],
          config: baseConfig,
        );

        expect(ranked.first.evaluation.topicId, 'a');
      },
    );

    test('exam importance can raise candidate priority', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'a',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
            },
            signalStrength: 0.50,
            examImportance: 0.20,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'b',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
            },
            signalStrength: 0.50,
            examImportance: 0.90,
            hasBridge: false,
          ),
        ],
        config: baseConfig,
      );

      expect(ranked.first.evaluation.topicId, 'b');
    });

    test('source diversity can raise candidate priority', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'a',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'b',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.progress,
              CandidateSource.practice,
              CandidateSource.repair,
              CandidateSource.measurement,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
        ],
        config: baseConfig,
      );

      expect(ranked.first.evaluation.topicId, 'b');
    });

    test('bridge requirement applies ranking cost', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'a',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
              CandidateSource.measurement,
            },
            signalStrength: 0.70,
            examImportance: 0.60,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'b',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
              CandidateSource.measurement,
            },
            signalStrength: 0.70,
            examImportance: 0.60,
            hasBridge: true,
          ),
        ],
        config: baseConfig,
      );

      expect(ranked.first.evaluation.topicId, 'a');
    });

    test('uses topic id as deterministic tie-break', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'beta',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
              CandidateSource.measurement,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'alpha',
            primarySource: CandidateSource.repair,
            sources: {
              CandidateSource.repair,
              CandidateSource.measurement,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
        ],
        config: baseConfig,
      );

      expect(ranked[0].evaluation.topicId, 'alpha');
      expect(ranked[1].evaluation.topicId, 'beta');
    });

    test('is deterministic for identical input', () {
      final evaluations = [
        evaluation(
          topicId: 'fonksiyonlar',
          primarySource: CandidateSource.repair,
          sources: {
            CandidateSource.repair,
            CandidateSource.measurement,
            CandidateSource.practice,
          },
          signalStrength: 0.80,
          examImportance: 0.90,
          hasBridge: false,
        ),
        evaluation(
          topicId: 'trigonometri',
          primarySource: CandidateSource.repair,
          sources: {
            CandidateSource.repair,
            CandidateSource.measurement,
          },
          signalStrength: 0.70,
          examImportance: 0.85,
          hasBridge: false,
        ),
      ];

      final first = rankCandidates(
        evaluations: evaluations,
        config: baseConfig,
      );

      final second = rankCandidates(
        evaluations: evaluations,
        config: baseConfig,
      );

      expect(first.length, second.length);

      for (var i = 0; i < first.length; i++) {
        expect(
          first[i].evaluation.topicId,
          second[i].evaluation.topicId,
        );
        expect(first[i].score, second[i].score);
      }
    });
  });

  group('rankCandidates - planning modes', () {
    test(
      'preExam favors measurement over otherwise equal progress candidate',
      () {
        final ranked = rankCandidates(
          evaluations: [
            evaluation(
              topicId: 'progress_topic',
              primarySource: CandidateSource.progress,
              sources: {
                CandidateSource.progress,
              },
              signalStrength: 0.60,
              examImportance: 0.60,
              hasBridge: false,
            ),
            evaluation(
              topicId: 'measurement_topic',
              primarySource: CandidateSource.measurement,
              sources: {
                CandidateSource.measurement,
              },
              signalStrength: 0.60,
              examImportance: 0.60,
              hasBridge: false,
            ),
          ],
          config: modeAwareConfig,
          planningMode: PlanningMode.preExam,
        );

        expect(
          ranked.first.evaluation.topicId,
          'measurement_topic',
        );
      },
    );

    test(
      'preExam applies additional penalty to bridge-requiring progress',
      () {
        final ranked = rankCandidates(
          evaluations: [
            evaluation(
              topicId: 'bridge_progress',
              primarySource: CandidateSource.progress,
              sources: {
                CandidateSource.progress,
              },
              signalStrength: 0.75,
              examImportance: 0.70,
              hasBridge: true,
            ),
            evaluation(
              topicId: 'direct_progress',
              primarySource: CandidateSource.progress,
              sources: {
                CandidateSource.progress,
              },
              signalStrength: 0.75,
              examImportance: 0.70,
              hasBridge: false,
            ),
          ],
          config: modeAwareConfig,
          planningMode: PlanningMode.preExam,
        );

        expect(
          ranked.first.evaluation.topicId,
          'direct_progress',
        );
      },
    );

    test(
      'postExam favors repair over otherwise equal measurement candidate',
      () {
        final ranked = rankCandidates(
          evaluations: [
            evaluation(
              topicId: 'measurement_topic',
              primarySource: CandidateSource.measurement,
              sources: {
                CandidateSource.measurement,
              },
              signalStrength: 0.65,
              examImportance: 0.60,
              hasBridge: false,
            ),
            evaluation(
              topicId: 'repair_topic',
              primarySource: CandidateSource.repair,
              sources: {
                CandidateSource.repair,
              },
              signalStrength: 0.65,
              examImportance: 0.60,
              hasBridge: false,
            ),
          ],
          config: modeAwareConfig,
          planningMode: PlanningMode.postExam,
        );

        expect(
          ranked.first.evaluation.topicId,
          'repair_topic',
        );
      },
    );

    test(
      'normal mode favors repair when mode bonus is configured',
      () {
        final ranked = rankCandidates(
          evaluations: [
            evaluation(
              topicId: 'progress_topic',
              primarySource: CandidateSource.progress,
              sources: {
                CandidateSource.progress,
              },
              signalStrength: 0.65,
              examImportance: 0.60,
              hasBridge: false,
            ),
            evaluation(
              topicId: 'repair_topic',
              primarySource: CandidateSource.repair,
              sources: {
                CandidateSource.repair,
              },
              signalStrength: 0.65,
              examImportance: 0.60,
              hasBridge: false,
            ),
          ],
          config: modeAwareConfig,
          planningMode: PlanningMode.normal,
        );

        expect(
          ranked.first.evaluation.topicId,
          'repair_topic',
        );
      },
    );

    test(
      'avoidance does not invent ranking changes before adaptation exists',
      () {
        final evaluations = [
          evaluation(
            topicId: 'beta',
            primarySource: CandidateSource.progress,
            sources: {
              CandidateSource.progress,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'alpha',
            primarySource: CandidateSource.progress,
            sources: {
              CandidateSource.progress,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
        ];

        final normal = rankCandidates(
          evaluations: evaluations,
          config: modeAwareConfig,
          planningMode: PlanningMode.normal,
        );

        final avoidance = rankCandidates(
          evaluations: evaluations,
          config: modeAwareConfig,
          planningMode: PlanningMode.avoidance,
        );

        expect(
          avoidance.map((candidate) => candidate.evaluation.topicId),
          normal.map((candidate) => candidate.evaluation.topicId),
        );
      },
    );

    test(
      'zero mode weights preserve legacy ranking behavior',
      () {
        final evaluations = [
          evaluation(
            topicId: 'beta',
            primarySource: CandidateSource.progress,
            sources: {
              CandidateSource.progress,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'alpha',
            primarySource: CandidateSource.measurement,
            sources: {
              CandidateSource.measurement,
            },
            signalStrength: 0.60,
            examImportance: 0.50,
            hasBridge: false,
          ),
        ];

        final normal = rankCandidates(
          evaluations: evaluations,
          config: baseConfig,
          planningMode: PlanningMode.normal,
        );

        final preExam = rankCandidates(
          evaluations: evaluations,
          config: baseConfig,
          planningMode: PlanningMode.preExam,
        );

        expect(
          preExam.map((candidate) => candidate.evaluation.topicId),
          normal.map((candidate) => candidate.evaluation.topicId),
        );
      },
    );
  });
}