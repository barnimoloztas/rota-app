import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/repair_signal.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/engine/signal/repair_signal_generator.dart';

void main() {
  const config = RepairSignalConfig(
    lowMasteryStrengthByBand: {
      MasteryBand.learning: 0.90,
      MasteryBand.developing: 0.65,
    },
  );

  StudentTopicState state({
    required String topicId,
    required bool hasEvidence,
    required MasteryBand band,
    required double score,
    required double confidence,
  }) {
    final calculatedAt = DateTime.utc(2026, 8, 14);

    return StudentTopicState(
      topicId: topicId,
      hasEvidence: hasEvidence,
      mastery: Mastery(
        score: score,
        confidence: confidence,
      ),
      masteryBand: band,
      lastMeaningfulEvidenceAt:
          hasEvidence ? DateTime.utc(2026, 8, 13) : null,
      calculatedAt: calculatedAt,
    );
  }

  StudentLearningSnapshot snapshot(
    Map<String, StudentTopicState> states,
  ) {
    return StudentLearningSnapshot(
      graphVersion: '1.0.0',
      calculatedAt: DateTime.utc(2026, 8, 14),
      topicStates: states,
    );
  }

  group('generateRepairSignals', () {
    test('does not generate repair signal for untouched topic', () {
      final result = generateRepairSignals(
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            hasEvidence: false,
            band: MasteryBand.notStarted,
            score: 0.0,
            confidence: 0.0,
          ),
        }),
        config: config,
      );

      expect(result, isEmpty);
    });

    test('generates low-mastery repair signal for learning band', () {
      final result = generateRepairSignals(
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            hasEvidence: true,
            band: MasteryBand.learning,
            score: 30.0,
            confidence: 0.55,
          ),
        }),
        config: config,
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
      expect(result.first.reason, RepairSignalReason.lowMastery);
      expect(result.first.strength, 0.90);
    });

    test('generates configured strength for developing band', () {
      final result = generateRepairSignals(
        snapshot: snapshot({
          'turev': state(
            topicId: 'turev',
            hasEvidence: true,
            band: MasteryBand.developing,
            score: 58.0,
            confidence: 0.70,
          ),
        }),
        config: config,
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'turev');
      expect(result.first.reason, RepairSignalReason.lowMastery);
      expect(result.first.strength, 0.65);
    });

    test('does not generate repair signal for unconfigured band', () {
      final result = generateRepairSignals(
        snapshot: snapshot({
          'integral': state(
            topicId: 'integral',
            hasEvidence: true,
            band: MasteryBand.proficient,
            score: 82.0,
            confidence: 0.80,
          ),
        }),
        config: config,
      );

      expect(result, isEmpty);
    });

    test('can generate repair signals for multiple topics', () {
      final result = generateRepairSignals(
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            hasEvidence: true,
            band: MasteryBand.learning,
            score: 28.0,
            confidence: 0.50,
          ),
          'limit_ve_sureklilik': state(
            topicId: 'limit_ve_sureklilik',
            hasEvidence: true,
            band: MasteryBand.developing,
            score: 55.0,
            confidence: 0.65,
          ),
          'turev': state(
            topicId: 'turev',
            hasEvidence: true,
            band: MasteryBand.consolidated,
            score: 92.0,
            confidence: 0.85,
          ),
        }),
        config: config,
      );

      expect(result, hasLength(2));

      expect(
        result.map((signal) => signal.topicId),
        containsAll({
          'fonksiyonlar',
          'limit_ve_sureklilik',
        }),
      );
    });

    test('does not infer chronic weakness or performance decline', () {
      final result = generateRepairSignals(
        snapshot: snapshot({
          'trigonometri': state(
            topicId: 'trigonometri',
            hasEvidence: true,
            band: MasteryBand.learning,
            score: 25.0,
            confidence: 0.60,
          ),
        }),
        config: config,
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        RepairSignalReason.lowMastery,
      );
    });
  });
}