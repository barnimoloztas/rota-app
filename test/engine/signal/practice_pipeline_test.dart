import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/practice_signal.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/candidate/practice_candidate_generator.dart';
import 'package:rota_app/engine/signal/practice_signal_generator.dart';

void main() {
  group('practice signal to candidate pipeline', () {
    test(
      'P1 lifecycle becomes practice candidate with preserved reason',
      () {
        final lifecycle = TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: DateTime.utc(2026, 8, 10),
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        );

        final signals = generatePracticeSignals(
          lifecycles: [lifecycle],
          evaluatedAt: DateTime.utc(2026, 8, 10),
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          PracticeSignalReason.initialPractice,
        );
        expect(signals.first.strength, 0.0);

        final candidate = generatePracticeCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'fonksiyonlar');
        expect(
          candidate.primarySource,
          CandidateSource.practice,
        );
        expect(candidate.signals, hasLength(1));
        expect(
          candidate.signals.first.reason,
          CandidateReason.initialPractice,
        );
        expect(candidate.signals.first.strength, 0.0);
      },
    );

    test(
      'later practice lifecycle becomes development candidate',
      () {
        final lifecycle = TopicLearningLifecycle(
          topicId: 'turev',
          progressCompletedAt: DateTime.utc(2026, 8, 8),
          completedInitialPracticeCount: 2,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 8),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 10),
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        );

        final signals = generatePracticeSignals(
          lifecycles: [lifecycle],
          evaluatedAt: DateTime.utc(2026, 8, 11),
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          PracticeSignalReason.practiceDevelopment,
        );
        expect(signals.first.strength, 0.0);

        final candidate = generatePracticeCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'turev');
        expect(
          candidate.primarySource,
          CandidateSource.practice,
        );
        expect(
          candidate.signals.first.reason,
          CandidateReason.practiceDevelopment,
        );
        expect(candidate.signals.first.strength, 0.0);
      },
    );
  });
}