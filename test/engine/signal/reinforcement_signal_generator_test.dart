import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/reinforcement_signal.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/engine/signal/reinforcement_signal_generator.dart';

void main() {
  const config = ReinforcementSignalConfig(
    strengthByBand: {
      MasteryBand.proficient: 0.55,
      MasteryBand.consolidated: 0.35,
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

  group('generateReinforcementSignals', () {
    test('does not generate reinforcement for untouched topic', () {
      final result = generateReinforcementSignals(
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

    test('generates mastery-maintenance signal for proficient band', () {
      final result = generateReinforcementSignals(
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            hasEvidence: true,
            band: MasteryBand.proficient,
            score: 82.0,
            confidence: 0.80,
          ),
        }),
        config: config,
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
      expect(
        result.first.reason,
        ReinforcementSignalReason.masteryMaintenance,
      );
      expect(result.first.strength, 0.55);
    });

    test('generates configured strength for consolidated band', () {
      final result = generateReinforcementSignals(
        snapshot: snapshot({
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

      expect(result, hasLength(1));
      expect(result.first.topicId, 'turev');
      expect(
        result.first.reason,
        ReinforcementSignalReason.masteryMaintenance,
      );
      expect(result.first.strength, 0.35);
    });

    test('does not generate signal for unconfigured band', () {
      final result = generateReinforcementSignals(
        snapshot: snapshot({
          'integral': state(
            topicId: 'integral',
            hasEvidence: true,
            band: MasteryBand.developing,
            score: 58.0,
            confidence: 0.70,
          ),
        }),
        config: config,
      );

      expect(result, isEmpty);
    });

    test('can generate reinforcement signals for multiple topics', () {
      final result = generateReinforcementSignals(
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            hasEvidence: true,
            band: MasteryBand.proficient,
            score: 82.0,
            confidence: 0.80,
          ),
          'turev': state(
            topicId: 'turev',
            hasEvidence: true,
            band: MasteryBand.consolidated,
            score: 92.0,
            confidence: 0.85,
          ),
          'limit_ve_sureklilik': state(
            topicId: 'limit_ve_sureklilik',
            hasEvidence: true,
            band: MasteryBand.learning,
            score: 30.0,
            confidence: 0.55,
          ),
        }),
        config: config,
      );

      expect(result, hasLength(2));

      expect(
        result.map((signal) => signal.topicId),
        containsAll({
          'fonksiyonlar',
          'turev',
        }),
      );
    });

    test('does not invent needs-practice reason', () {
      final result = generateReinforcementSignals(
        snapshot: snapshot({
          'trigonometri': state(
            topicId: 'trigonometri',
            hasEvidence: true,
            band: MasteryBand.proficient,
            score: 84.0,
            confidence: 0.80,
          ),
        }),
        config: config,
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        ReinforcementSignalReason.masteryMaintenance,
      );
    });
  });
}