import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/practice/practice_completion_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_task_generator.dart';

void main() {
  group('subject reinforcement start scenario', () {
    test(
      'first practice completion date starts the subject reinforcement schedule',
      () {
        var topicLifecycle = TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: DateTime.utc(2026, 8, 1),
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
        );

        topicLifecycle = completePractice(
          lifecycle: topicLifecycle,
          completedAt: DateTime.utc(2026, 8, 1),
        );

        final firstPracticeCompletedAt =
            topicLifecycle.firstPracticeCompletedAt;

        expect(
          firstPracticeCompletedAt,
          DateTime.utc(2026, 8, 1),
        );

        final subjectLifecycle = SubjectReinforcementLifecycle(
          subjectId: 'mathematics',
          startedAt: firstPracticeCompletedAt!,
          completedInitialReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        );

        final beforeDue = generateSubjectReinforcementTask(
          lifecycle: subjectLifecycle,
          evaluatedAt: DateTime.utc(2026, 8, 14),
        );

        expect(beforeDue, isNull);

        final due = generateSubjectReinforcementTask(
          lifecycle: subjectLifecycle,
          evaluatedAt: DateTime.utc(2026, 8, 15),
        );

        expect(due, isNotNull);
        expect(due!.subjectId, 'mathematics');
        expect(
          due.type,
          SubjectReinforcementTaskType.topicReinforcement,
        );
      },
    );
  });
}