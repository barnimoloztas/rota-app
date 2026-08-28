import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/engine/planning/untouched_daily_plan_composer.dart';

void main() {
  final evaluatedAt = DateTime.utc(2026, 8, 27);

  const rankedNormalTasks = [
    SubjectPlanTask(
      subjectId: 'mathematics',
      task: StudyTask(
        topicId: 'normal-a',
        type: StudyTaskType.repair,
        sourceTopicId: 'normal-a',
      ),
    ),
    SubjectPlanTask(
      subjectId: 'physics',
      task: StudyTask(
        topicId: 'normal-b',
        type: StudyTaskType.practice,
        sourceTopicId: 'normal-b',
      ),
    ),
    SubjectPlanTask(
      subjectId: 'chemistry',
      task: StudyTask(
        topicId: 'normal-c',
        type: StudyTaskType.progress,
        sourceTopicId: 'normal-c',
      ),
    ),
  ];

  final dueReinforcement = DailyReinforcementCandidate(
    id: 'subject:mathematics',
    dueAt: evaluatedAt,
    currentImportance: 0.8,
    task: const SubjectReinforcementTask(
      subjectId: 'mathematics',
      type: SubjectReinforcementTaskType.branchReinforcement,
    ),
  );

  SubjectPlanTask protectedTask(String topicId, String subjectId) {
    return SubjectPlanTask(
      subjectId: subjectId,
      task: StudyTask(
        topicId: topicId,
        type: StudyTaskType.practice,
        sourceTopicId: topicId,
      ),
    );
  }

  group('composeDailyPlan with protected tasks', () {
    test(
      'places reinforcement and one normal task after two protected tasks',
      () {
        final protectedTasks = [
          protectedTask('protected-a', 'mathematics'),
          protectedTask('protected-b', 'physics'),
        ];

        final draft = composeDailyPlan(
          protectedSubjectTasks: protectedTasks,
          rankedNormalTasks: rankedNormalTasks,
          reinforcementCandidates: [dueReinforcement],
          evaluatedAt: evaluatedAt,
        );

        expect(draft.protectedSubjectTasks, orderedEquals(protectedTasks));
        expect(
          draft.protectedTasks,
          orderedEquals(protectedTasks.map((plannedTask) => plannedTask.task)),
        );
        expect(draft.reinforcement, same(dueReinforcement));
        expect(draft.normalRoute.tasks.map((task) => task.topicId), [
          'normal-a',
        ]);
        expect(draft.taskCount, 4);
      },
    );

    test(
      'uses the last slot for reinforcement after three protected tasks',
      () {
        final protectedTasks = [
          protectedTask('protected-a', 'mathematics'),
          protectedTask('protected-b', 'physics'),
          protectedTask('protected-c', 'chemistry'),
        ];

        final draft = composeDailyPlan(
          protectedSubjectTasks: protectedTasks,
          rankedNormalTasks: rankedNormalTasks,
          reinforcementCandidates: [dueReinforcement],
          evaluatedAt: evaluatedAt,
        );

        expect(draft.protectedSubjectTasks, orderedEquals(protectedTasks));
        expect(draft.reinforcement, same(dueReinforcement));
        expect(draft.normalRoute.tasks, isEmpty);
        expect(draft.taskCount, 4);
      },
    );

    test('does not displace four protected tasks for reinforcement', () {
      final protectedTasks = [
        protectedTask('protected-a', 'mathematics'),
        protectedTask('protected-b', 'physics'),
        protectedTask('protected-c', 'chemistry'),
        protectedTask('protected-d', 'biology'),
      ];

      final draft = composeDailyPlan(
        protectedSubjectTasks: protectedTasks,
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [dueReinforcement],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.protectedSubjectTasks, orderedEquals(protectedTasks));
      expect(draft.reinforcement, isNull);
      expect(draft.normalRoute.tasks, isEmpty);
      expect(draft.taskCount, 4);
    });

    test('fills remaining slots with normal tasks when none is due', () {
      final protectedTasks = [
        protectedTask('protected-a', 'mathematics'),
        protectedTask('protected-b', 'physics'),
      ];

      final draft = composeDailyPlan(
        protectedSubjectTasks: protectedTasks,
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: const [],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.reinforcement, isNull);
      expect(draft.normalRoute.tasks.map((task) => task.topicId), [
        'normal-a',
        'normal-b',
      ]);
      expect(
        draft.normalSubjectTasks.map((plannedTask) => plannedTask.subjectId),
        ['mathematics', 'physics'],
      );
      expect(draft.taskCount, 4);
    });
  });
}
