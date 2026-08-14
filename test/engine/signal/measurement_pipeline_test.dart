import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/measurement_signal.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/measurement_candidate_generator.dart';
import 'package:rota_app/engine/signal/measurement_signal_generator.dart';

void main() {
  const config = MeasurementSignalConfig(
    lowConfidenceThreshold: 0.60,
    insufficientEvidenceConfidenceThreshold: 0.25,
    staleEvidenceAfter: Duration(days: 30),
  );

  StudentLearningSnapshot snapshot({
    required String topicId,
    required double confidence,
    required DateTime lastEvidenceAt,
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
            score: 85.0,
            confidence: confidence,
          ),
          masteryBand: MasteryBand.consolidated,
          lastMeaningfulEvidenceAt: lastEvidenceAt,
          calculatedAt: calculatedAt,
        ),
      },
    );
  }

  group('measurement signal to candidate pipeline', () {
    test(
      'low confidence state becomes measurement candidate with preserved reason',
      () {
        final signals = generateMeasurementSignals(
          snapshot: snapshot(
            topicId: 'fonksiyonlar',
            confidence: 0.40,
            lastEvidenceAt: DateTime.utc(2026, 8, 13),
          ),
          now: DateTime.utc(2026, 8, 14),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          MeasurementSignalReason.lowConfidence,
        );

        final candidate = generateMeasurementCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'fonksiyonlar');
        expect(
          candidate.primarySource,
          CandidateSource.measurement,
        );
        expect(candidate.signals, hasLength(1));
        expect(
          candidate.signals.first.reason,
          CandidateReason.lowConfidence,
        );
      },
    );

    test(
      'stale evidence state becomes measurement candidate with preserved reason',
      () {
        final signals = generateMeasurementSignals(
          snapshot: snapshot(
            topicId: 'integral',
            confidence: 0.85,
            lastEvidenceAt: DateTime.utc(2026, 6, 1),
          ),
          now: DateTime.utc(2026, 8, 14),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          MeasurementSignalReason.staleEvidence,
        );

        final candidate = generateMeasurementCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'integral');
        expect(
          candidate.primarySource,
          CandidateSource.measurement,
        );
        expect(candidate.signals, hasLength(1));
        expect(
          candidate.signals.first.reason,
          CandidateReason.staleEvidence,
        );
      },
    );

    test(
      'very low confidence becomes insufficient-evidence measurement candidate',
      () {
        final signals = generateMeasurementSignals(
          snapshot: snapshot(
            topicId: 'turev',
            confidence: 0.20,
            lastEvidenceAt: DateTime.utc(2026, 8, 13),
          ),
          now: DateTime.utc(2026, 8, 14),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          MeasurementSignalReason.insufficientEvidence,
        );

        final candidate = generateMeasurementCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'turev');
        expect(
          candidate.signals.first.reason,
          CandidateReason.insufficientEvidence,
        );
      },
    );

    test(
      'fresh high-confidence state produces no measurement candidate',
      () {
        final signals = generateMeasurementSignals(
          snapshot: snapshot(
            topicId: 'trigonometri',
            confidence: 0.90,
            lastEvidenceAt: DateTime.utc(2026, 8, 12),
          ),
          now: DateTime.utc(2026, 8, 14),
          config: config,
        );

        expect(signals, isEmpty);
      },
    );
  });
}