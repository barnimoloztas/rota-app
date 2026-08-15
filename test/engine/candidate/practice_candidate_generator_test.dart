import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/practice_signal.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/practice_candidate_generator.dart';

void main() {
  group('generatePracticeCandidate', () {
    test('creates practice candidate for initial practice', () {
      const signal = PracticeSignal(
        topicId: 'fonksiyonlar',
        reason: PracticeSignalReason.initialPractice,
        strength: 0.80,
      );

      final candidate = generatePracticeCandidate(
        signal: signal,
      );

      expect(candidate.topicId, 'fonksiyonlar');
      expect(
        candidate.primarySource,
        CandidateSource.practice,
      );
      expect(
        candidate.sources,
        {
          CandidateSource.practice,
        },
      );
      expect(candidate.requiresBridge, isFalse);
      expect(candidate.bridgeTopicId, isNull);

      expect(candidate.signals, hasLength(1));
      expect(
        candidate.signals.first.source,
        CandidateSource.practice,
      );
      expect(
        candidate.signals.first.reason,
        CandidateReason.initialPractice,
      );
      expect(candidate.signals.first.strength, 0.80);
    });

    test('preserves practice development as a distinct reason', () {
      const signal = PracticeSignal(
        topicId: 'turev',
        reason: PracticeSignalReason.practiceDevelopment,
        strength: 0.70,
      );

      final candidate = generatePracticeCandidate(
        signal: signal,
      );

      expect(
        candidate.signals.first.reason,
        CandidateReason.practiceDevelopment,
      );
    });

    test('preserves practice maintenance as a distinct reason', () {
      const signal = PracticeSignal(
        topicId: 'integral',
        reason: PracticeSignalReason.practiceMaintenance,
        strength: 0.60,
      );

      final candidate = generatePracticeCandidate(
        signal: signal,
      );

      expect(
        candidate.signals.first.reason,
        CandidateReason.practiceMaintenance,
      );
    });
  });
}