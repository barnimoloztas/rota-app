import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/reinforcement_signal.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/topic.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/candidate/reinforcement_candidate_generator.dart';
import 'package:rota_app/engine/signal/reinforcement_signal_generator.dart';

void main() {
  TopicLearningLifecycle lifecycle({
    required TopicId topicId,
    required DateTime? progressCompletedAt,
    required int completedInitialPracticeCount,
    required DateTime? firstPracticeCompletedAt,
    required DateTime? lastPracticeCompletedAt,
    required int completedReinforcementCount,
    required DateTime? lastReinforcementCompletedAt,
  }) {
    return TopicLearningLifecycle(
      topicId: topicId,
      progressCompletedAt: progressCompletedAt,
      completedInitialPracticeCount: completedInitialPracticeCount,
      firstPracticeCompletedAt: firstPracticeCompletedAt,
      lastPracticeCompletedAt: lastPracticeCompletedAt,
      completedReinforcementCount: completedReinforcementCount,
      lastReinforcementCompletedAt: lastReinforcementCompletedAt,
    );
  }

  group('reinforcement signal to candidate pipeline', () {
    test(
      'due reinforcement becomes candidate with preserved reason',
      () {
        final signals = generateReinforcementSignals(
          lifecycles: [
            lifecycle(
              topicId: 'fonksiyonlar',
              progressCompletedAt: DateTime.utc(2026, 7, 31),
              completedInitialPracticeCount: 1,
              firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
              lastPracticeCompletedAt: DateTime.utc(2026, 8, 1),
              completedReinforcementCount: 0,
              lastReinforcementCompletedAt: null,
            ),
          ],
          evaluatedAt: DateTime.utc(2026, 8, 15),
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          ReinforcementSignalReason.masteryMaintenance,
        );
        expect(signals.first.strength, 0.0);

        final candidate = generateReinforcementCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'fonksiyonlar');
        expect(
          candidate.primarySource,
          CandidateSource.reinforcement,
        );
        expect(candidate.signals, hasLength(1));
        expect(
          candidate.signals.first.reason,
          CandidateReason.masteryMaintenance,
        );
        expect(candidate.signals.first.strength, 0.0);
      },
    );

    test(
      'next due reinforcement becomes candidate with neutral strength',
      () {
        final signals = generateReinforcementSignals(
          lifecycles: [
            lifecycle(
              topicId: 'turev',
              progressCompletedAt: DateTime.utc(2026, 7, 19),
              completedInitialPracticeCount: 4,
              firstPracticeCompletedAt: DateTime.utc(2026, 7, 20),
              lastPracticeCompletedAt: DateTime.utc(2026, 7, 26),
              completedReinforcementCount: 1,
              lastReinforcementCompletedAt: DateTime.utc(2026, 8, 8),
            ),
          ],
          evaluatedAt: DateTime.utc(2026, 8, 15),
        );

        expect(signals, hasLength(1));
        expect(signals.first.strength, 0.0);

        final candidate = generateReinforcementCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'turev');
        expect(
          candidate.primarySource,
          CandidateSource.reinforcement,
        );
        expect(candidate.signals.first.strength, 0.0);
      },
    );

    test(
      'not-due lifecycle produces no reinforcement candidate',
      () {
        final signals = generateReinforcementSignals(
          lifecycles: [
            lifecycle(
              topicId: 'limit_ve_sureklilik',
              progressCompletedAt: DateTime.utc(2026, 8, 4),
              completedInitialPracticeCount: 1,
              firstPracticeCompletedAt: DateTime.utc(2026, 8, 5),
              lastPracticeCompletedAt: DateTime.utc(2026, 8, 5),
              completedReinforcementCount: 0,
              lastReinforcementCompletedAt: null,
            ),
          ],
          evaluatedAt: DateTime.utc(2026, 8, 15),
        );

        expect(signals, isEmpty);
      },
    );

    test(
      'reinforcement pipeline does not invent needs-practice reason',
      () {
        final signals = generateReinforcementSignals(
          lifecycles: [
            lifecycle(
              topicId: 'trigonometri',
              progressCompletedAt: DateTime.utc(2026, 7, 31),
              completedInitialPracticeCount: 1,
              firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
              lastPracticeCompletedAt: DateTime.utc(2026, 8, 1),
              completedReinforcementCount: 0,
              lastReinforcementCompletedAt: null,
            ),
          ],
          evaluatedAt: DateTime.utc(2026, 8, 15),
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          ReinforcementSignalReason.masteryMaintenance,
        );

        final candidate = generateReinforcementCandidate(
          signal: signals.first,
        );

        expect(
          candidate.signals.first.reason,
          CandidateReason.masteryMaintenance,
        );
      },
    );
  });
}