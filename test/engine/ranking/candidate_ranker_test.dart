import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/candidate_evaluation.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/ranking/candidate_ranker.dart';

void main() {
  const config = RankingConfig(
    signalStrengthWeight: 0.50,
    examImportanceWeight: 0.30,
    sourceDiversityWeight: 0.20,
    bridgeCostWeight: 0.10,
  );

  CandidateEvaluation evaluation({
    required String topicId,
    required double signalStrength,
    required double examImportance,
    required int sourceCount,
    required bool hasBridge,
  }) {
    return CandidateEvaluation(
      topicId: topicId,
      candidate: StudyCandidate(
        topicId: topicId,
        primarySource: CandidateSource.repair,
        sources: {
          CandidateSource.repair,
        },
        requiresBridge: hasBridge,
        bridgeTopicId: hasBridge ? 'bridge_topic' : null,
      ),
      signalStrength: signalStrength,
      sourceCount: sourceCount,
      hasBridge: hasBridge,
      examImportance: examImportance,
    );
  }

  group('rankCandidates', () {
    test('ranks higher signal strength first when other inputs are equal', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'a',
            signalStrength: 0.80,
            examImportance: 0.50,
            sourceCount: 1,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'b',
            signalStrength: 0.40,
            examImportance: 0.50,
            sourceCount: 1,
            hasBridge: false,
          ),
        ],
        config: config,
      );

      expect(ranked.first.evaluation.topicId, 'a');
    });

    test('exam importance can raise candidate priority', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'a',
            signalStrength: 0.50,
            examImportance: 0.20,
            sourceCount: 1,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'b',
            signalStrength: 0.50,
            examImportance: 0.90,
            sourceCount: 1,
            hasBridge: false,
          ),
        ],
        config: config,
      );

      expect(ranked.first.evaluation.topicId, 'b');
    });

    test('source diversity can raise candidate priority', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'a',
            signalStrength: 0.60,
            examImportance: 0.50,
            sourceCount: 1,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'b',
            signalStrength: 0.60,
            examImportance: 0.50,
            sourceCount: 4,
            hasBridge: false,
          ),
        ],
        config: config,
      );

      expect(ranked.first.evaluation.topicId, 'b');
    });

    test('bridge requirement applies ranking cost', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'a',
            signalStrength: 0.70,
            examImportance: 0.60,
            sourceCount: 2,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'b',
            signalStrength: 0.70,
            examImportance: 0.60,
            sourceCount: 2,
            hasBridge: true,
          ),
        ],
        config: config,
      );

      expect(ranked.first.evaluation.topicId, 'a');
    });

    test('uses topic id as deterministic tie-break', () {
      final ranked = rankCandidates(
        evaluations: [
          evaluation(
            topicId: 'beta',
            signalStrength: 0.60,
            examImportance: 0.50,
            sourceCount: 2,
            hasBridge: false,
          ),
          evaluation(
            topicId: 'alpha',
            signalStrength: 0.60,
            examImportance: 0.50,
            sourceCount: 2,
            hasBridge: false,
          ),
        ],
        config: config,
      );

      expect(ranked[0].evaluation.topicId, 'alpha');
      expect(ranked[1].evaluation.topicId, 'beta');
    });

    test('is deterministic for identical input', () {
      final evaluations = [
        evaluation(
          topicId: 'fonksiyonlar',
          signalStrength: 0.80,
          examImportance: 0.90,
          sourceCount: 3,
          hasBridge: false,
        ),
        evaluation(
          topicId: 'trigonometri',
          signalStrength: 0.70,
          examImportance: 0.85,
          sourceCount: 2,
          hasBridge: false,
        ),
      ];

      final first = rankCandidates(
        evaluations: evaluations,
        config: config,
      );

      final second = rankCandidates(
        evaluations: evaluations,
        config: config,
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
}