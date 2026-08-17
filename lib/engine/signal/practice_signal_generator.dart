import '../../domain/practice_signal.dart';
import '../../domain/topic_learning_lifecycle.dart';

List<PracticeSignal> generatePracticeSignals({
  required Iterable<TopicLearningLifecycle> lifecycles,
  required DateTime evaluatedAt,
}) {
  final signals = <PracticeSignal>[];

  for (final lifecycle in lifecycles) {
    final signal = _practiceSignalForLifecycle(
      lifecycle: lifecycle,
      evaluatedAt: evaluatedAt,
    );

    if (signal != null) {
      signals.add(signal);
    }
  }

  return List.unmodifiable(signals);
}

PracticeSignal? _practiceSignalForLifecycle({
  required TopicLearningLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  if (lifecycle.progressCompletedAt == null) {
    return null;
  }

  if (lifecycle.completedInitialPracticeCount >= 4) {
    return null;
  }

  if (lifecycle.completedInitialPracticeCount == 0) {
    if (evaluatedAt.isBefore(lifecycle.progressCompletedAt!)) {
      return null;
    }

    return PracticeSignal(
      topicId: lifecycle.topicId,
      reason: PracticeSignalReason.initialPractice,
      strength: 0.0,
    );
  }

  final nextPracticeDueAt = lifecycle.lastPracticeCompletedAt!.add(
    const Duration(days: 1),
  );

  if (evaluatedAt.isBefore(nextPracticeDueAt)) {
    return null;
  }

  return PracticeSignal(
    topicId: lifecycle.topicId,
    reason: PracticeSignalReason.practiceDevelopment,
    strength: 0.0,
  );
}