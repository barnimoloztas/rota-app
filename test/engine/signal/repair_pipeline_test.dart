import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/repair_signal.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/repair_candidate_generator.dart';
import 'package:rota_app/engine/signal/repair_signal_generator.dart';

void main() {
  const config = RepairSignalConfig(
    lowMasteryStrengthByBand: {
      MasteryBand.learning: 0.90,
      MasteryBand.developing: 0.65,
    },
  );

  StudentLearningSnapshot snapshot({
    required String topicId,
    required MasteryBand band,
    required double score,
    required double confidence,
  }) {
    final calculatedAt = DateTime.utc(2026, 8, 14);

    return StudentLearningSnapshot(
      graphVersion: '1.0.0',
      calculatedAt: calculatedAt,
      topicStates: {
        topicId: StudentTopicState(
          topicId: topicId,
          hasEvidence: true,
          mastery: Mastery(
            score: score,
            confidence: confidence,
          ),
          masteryBand: band,
          lastMeaningfulEvidenceAt: DateTime.utc(2026, 8, 13),
          calculatedAt: calculatedAt,
        ),
      },
    );
  }

  group('repair signal to candidate pipeline', () {
    test(
      'learning state becomes repair candidate with preserved low-mastery reason',
      () {
        final signals = generateRepairSignals(
          snapshot: snapshot(
            topicId: 'fonksiyonlar',
            band: MasteryBand.learning,
            score: 30.0,
            confidence: 0.55,
          ),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          RepairSignalReason.lowMastery,
        );
        expect(signals.first.strength, 0.90);

        final candidate = generateRepairCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'fonksiyonlar');
        expect(
          candidate.primarySource,
          CandidateSource.repair,
        );
        expect(candidate.signals, hasLength(1));
        expect(
          candidate.signals.first.reason,
          CandidateReason.lowMastery,
        );
        expect(candidate.signals.first.strength, 0.90);
      },
    );

    test(
      'developing state becomes repair candidate with configured strength',
      () {
        final signals = generateRepairSignals(
          snapshot: snapshot(
            topicId: 'limit_ve_sureklilik',
            band: MasteryBand.developing,
            score: 55.0,
            confidence: 0.70,
          ),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(signals.first.strength, 0.65);

        final candidate = generateRepairCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'limit_ve_sureklilik');
        expect(
          candidate.primarySource,
          CandidateSource.repair,
        );
        expect(candidate.signals.first.strength, 0.65);
      },
    );

    test(
      'proficient state produces no repair candidate when band is not configured',
      () {
        final signals = generateRepairSignals(
          snapshot: snapshot(
            topicId: 'turev',
            band: MasteryBand.proficient,
            score: 82.0,
            confidence: 0.80,
          ),
          config: config,
        );

        expect(signals, isEmpty);
      },
    );

    test(
      'repair pipeline does not invent chronic weakness or performance decline',
      () {
        final signals = generateRepairSignals(
          snapshot: snapshot(
            topicId: 'trigonometri',
            band: MasteryBand.learning,
            score: 25.0,
            confidence: 0.60,
          ),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          RepairSignalReason.lowMastery,
        );

        final candidate = generateRepairCandidate(
          signal: signals.first,
        );

        expect(
          candidate.signals.first.reason,
          CandidateReason.lowMastery,
        );
      },
    );
  });
}