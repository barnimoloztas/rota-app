import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/measurement_signal.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/measurement_candidate_generator.dart';

void main() {
  group('MeasurementSignal', () {
    test('stores topic, reason, and strength', () {
      const signal = MeasurementSignal(
        topicId: 'fonksiyonlar',
        reason: MeasurementSignalReason.lowConfidence,
        strength: 0.80,
      );

      expect(signal.topicId, 'fonksiyonlar');
      expect(signal.reason, MeasurementSignalReason.lowConfidence);
      expect(signal.strength, 0.80);
    });
  });

  group('generateMeasurementCandidate', () {
    test('creates candidate for low confidence', () {
      const signal = MeasurementSignal(
        topicId: 'fonksiyonlar',
        reason: MeasurementSignalReason.lowConfidence,
        strength: 0.80,
      );

      final candidate = generateMeasurementCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'fonksiyonlar');
      expect(
        candidate.primarySource,
        CandidateSource.measurement,
      );

      expect(
        candidate.sources,
        {
          CandidateSource.measurement,
        },
      );

      expect(candidate.requiresBridge, isFalse);
      expect(candidate.bridgeTopicId, isNull);

      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.source,
        CandidateSource.measurement,
      );
      expect(
        candidate.signals.first.reason,
        CandidateReason.lowConfidence,
      );
      expect(candidate.signals.first.strength, 0.80);
    });

    test('creates candidate for stale evidence', () {
      const signal = MeasurementSignal(
        topicId: 'turev',
        reason: MeasurementSignalReason.staleEvidence,
        strength: 0.65,
      );

      final candidate = generateMeasurementCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'turev');
      expect(
        candidate.primarySource,
        CandidateSource.measurement,
      );
      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.reason,
        CandidateReason.staleEvidence,
      );
      expect(candidate.signals.first.strength, 0.65);
    });

    test('creates candidate for insufficient evidence', () {
      const signal = MeasurementSignal(
        topicId: 'integral',
        reason: MeasurementSignalReason.insufficientEvidence,
        strength: 0.70,
      );

      final candidate = generateMeasurementCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'integral');
      expect(
        candidate.primarySource,
        CandidateSource.measurement,
      );
      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.reason,
        CandidateReason.insufficientEvidence,
      );
      expect(candidate.signals.first.strength, 0.70);
    });

    test('does not turn measurement need into a study task', () {
      const signal = MeasurementSignal(
        topicId: 'limit_ve_sureklilik',
        reason: MeasurementSignalReason.lowConfidence,
        strength: 0.90,
      );

      final candidate = generateMeasurementCandidate(
        signal: signal,
      );

      expect(
        candidate.primarySource,
        CandidateSource.measurement,
      );
      expect(candidate.requiresBridge, isFalse);
      expect(candidate.bridgeTopicId, isNull);
    });
  });
}