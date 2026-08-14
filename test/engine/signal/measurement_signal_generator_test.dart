import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/domain/measurement_signal.dart';
import 'package:rota_app/engine/signal/measurement_signal_generator.dart';

void main() {
  const config = MeasurementSignalConfig(
    lowConfidenceThreshold: 0.60,
    insufficientEvidenceConfidenceThreshold: 0.25,
    staleEvidenceAfter: Duration(days: 30),
  );

  StudentTopicState state({
    required String topicId,
    required bool hasEvidence,
    required double confidence,
    required DateTime? lastEvidenceAt,
  }) {
    return StudentTopicState(
      topicId: topicId,
      hasEvidence: hasEvidence,
      mastery: Mastery(
        score: 80.0,
        confidence: confidence,
      ),
      masteryBand: MasteryBand.consolidated,
      lastMeaningfulEvidenceAt: lastEvidenceAt,
      calculatedAt: DateTime.utc(2026, 8, 14),
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

  group('generateMeasurementSignals', () {
    test('does not generate signal for untouched topic', () {
      final result = generateMeasurementSignals(
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            hasEvidence: false,
            confidence: 0.0,
            lastEvidenceAt: null,
          ),
        }),
        now: DateTime.utc(2026, 8, 14),
        config: config,
      );

      expect(result, isEmpty);
    });

    test('generates insufficient evidence signal for very low confidence', () {
      final result = generateMeasurementSignals(
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            hasEvidence: true,
            confidence: 0.20,
            lastEvidenceAt: DateTime.utc(2026, 8, 13),
          ),
        }),
        now: DateTime.utc(2026, 8, 14),
        config: config,
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        MeasurementSignalReason.insufficientEvidence,
      );
      expect(result.first.topicId, 'fonksiyonlar');
    });

    test('generates low confidence signal below threshold', () {
      final result = generateMeasurementSignals(
        snapshot: snapshot({
          'turev': state(
            topicId: 'turev',
            hasEvidence: true,
            confidence: 0.40,
            lastEvidenceAt: DateTime.utc(2026, 8, 13),
          ),
        }),
        now: DateTime.utc(2026, 8, 14),
        config: config,
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        MeasurementSignalReason.lowConfidence,
      );
      expect(result.first.topicId, 'turev');
    });

    test('generates stale evidence signal when evidence is too old', () {
      final result = generateMeasurementSignals(
        snapshot: snapshot({
          'integral': state(
            topicId: 'integral',
            hasEvidence: true,
            confidence: 0.80,
            lastEvidenceAt: DateTime.utc(2026, 6, 1),
          ),
        }),
        now: DateTime.utc(2026, 8, 14),
        config: config,
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        MeasurementSignalReason.staleEvidence,
      );
      expect(result.first.topicId, 'integral');
    });

    test('can generate both low confidence and stale evidence signals', () {
      final result = generateMeasurementSignals(
        snapshot: snapshot({
          'limit_ve_sureklilik': state(
            topicId: 'limit_ve_sureklilik',
            hasEvidence: true,
            confidence: 0.45,
            lastEvidenceAt: DateTime.utc(2026, 6, 1),
          ),
        }),
        now: DateTime.utc(2026, 8, 14),
        config: config,
      );

      expect(result, hasLength(2));

      expect(
        result.map((signal) => signal.reason),
        containsAll({
          MeasurementSignalReason.lowConfidence,
          MeasurementSignalReason.staleEvidence,
        }),
      );
    });

    test('does not generate signal for fresh high-confidence state', () {
      final result = generateMeasurementSignals(
        snapshot: snapshot({
          'trigonometri': state(
            topicId: 'trigonometri',
            hasEvidence: true,
            confidence: 0.85,
            lastEvidenceAt: DateTime.utc(2026, 8, 10),
          ),
        }),
        now: DateTime.utc(2026, 8, 14),
        config: config,
      );

      expect(result, isEmpty);
    });
  });
}