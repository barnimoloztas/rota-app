import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/repair_signal.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/repair_candidate_generator.dart';

void main() {
  group('RepairSignal', () {
    test('stores topic, reason, and strength', () {
      const signal = RepairSignal(
        topicId: 'fonksiyonlar',
        reason: RepairSignalReason.lowMastery,
        strength: 0.75,
      );

      expect(signal.topicId, 'fonksiyonlar');
      expect(signal.reason, RepairSignalReason.lowMastery);
      expect(signal.strength, 0.75);
    });
  });

  group('generateRepairCandidate', () {
    test('creates a repair candidate from a repair signal', () {
      const signal = RepairSignal(
        topicId: 'fonksiyonlar',
        reason: RepairSignalReason.lowMastery,
        strength: 0.75,
      );

      final candidate = generateRepairCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'fonksiyonlar');
      expect(candidate.primarySource, CandidateSource.repair);

      expect(
        candidate.sources,
        {
          CandidateSource.repair,
        },
      );

      expect(candidate.requiresBridge, isFalse);
      expect(candidate.bridgeTopicId, isNull);

      expect(candidate.signals, hasLength(1));
      expect(candidate.signals.first.source, CandidateSource.repair);
      expect(candidate.signals.first.reason, CandidateReason.lowMastery);
      expect(candidate.signals.first.strength, 0.75);
    });

    test('maps chronic weakness reason into candidate signal', () {
      const signal = RepairSignal(
        topicId: 'trigonometri',
        reason: RepairSignalReason.chronicWeakness,
        strength: 0.90,
      );

      final candidate = generateRepairCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'trigonometri');
      expect(candidate.primarySource, CandidateSource.repair);

      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.reason,
        CandidateReason.chronicWeakness,
      );
      expect(candidate.signals.first.strength, 0.90);
    });

    test('maps performance decline reason into candidate signal', () {
      const signal = RepairSignal(
        topicId: 'turev',
        reason: RepairSignalReason.performanceDecline,
        strength: 0.60,
      );

      final candidate = generateRepairCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'turev');
      expect(candidate.primarySource, CandidateSource.repair);

      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.reason,
        CandidateReason.performanceDecline,
      );
      expect(candidate.signals.first.strength, 0.60);
    });

    test('does not convert signal strength into a ranking score', () {
      const signal = RepairSignal(
        topicId: 'integral',
        reason: RepairSignalReason.lowMastery,
        strength: 0.95,
      );

      final candidate = generateRepairCandidate(
        signal: signal,
      );

      expect(candidate.signals.first.strength, 0.95);

      // CandidateSignal.strength is preserved as evidence for later ranking.
      // No final ranking score exists at this layer.
      expect(candidate.primarySource, CandidateSource.repair);
    });
  });
}