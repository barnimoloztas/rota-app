import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/reinforcement_signal.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/reinforcement_candidate_generator.dart';

void main() {
  group('ReinforcementSignal', () {
    test('stores topic, reason, and strength', () {
      const signal = ReinforcementSignal(
        topicId: 'fonksiyonlar',
        reason: ReinforcementSignalReason.needsPractice,
        strength: 0.70,
      );

      expect(signal.topicId, 'fonksiyonlar');
      expect(signal.reason, ReinforcementSignalReason.needsPractice);
      expect(signal.strength, 0.70);
    });
  });

  group('generateReinforcementCandidate', () {
    test('creates reinforcement candidate for practice need', () {
      const signal = ReinforcementSignal(
        topicId: 'fonksiyonlar',
        reason: ReinforcementSignalReason.needsPractice,
        strength: 0.70,
      );

      final candidate = generateReinforcementCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'fonksiyonlar');
      expect(
        candidate.primarySource,
        CandidateSource.reinforcement,
      );
      expect(
        candidate.sources,
        {
          CandidateSource.reinforcement,
        },
      );
      expect(candidate.requiresBridge, isFalse);
      expect(candidate.bridgeTopicId, isNull);

      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.source,
        CandidateSource.reinforcement,
      );
      expect(
        candidate.signals.first.reason,
        CandidateReason.needsPractice,
      );
      expect(candidate.signals.first.strength, 0.70);
    });

    test('creates reinforcement candidate for mastery maintenance', () {
      const signal = ReinforcementSignal(
        topicId: 'turev',
        reason: ReinforcementSignalReason.masteryMaintenance,
        strength: 0.55,
      );

      final candidate = generateReinforcementCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'turev');
      expect(
        candidate.primarySource,
        CandidateSource.reinforcement,
      );
      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.reason,
        CandidateReason.masteryMaintenance,
      );
      expect(candidate.signals.first.strength, 0.55);
    });

    test('does not turn signal strength into a final ranking score', () {
      const signal = ReinforcementSignal(
        topicId: 'integral',
        reason: ReinforcementSignalReason.needsPractice,
        strength: 0.95,
      );

      final candidate = generateReinforcementCandidate(
        signal: signal,
      );

      expect(candidate.signals.first.strength, 0.95);
      expect(
        candidate.primarySource,
        CandidateSource.reinforcement,
      );
    });
  });
}