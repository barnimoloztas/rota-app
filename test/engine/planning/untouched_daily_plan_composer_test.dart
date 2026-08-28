import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_task.dart';
import 'package:rota_app/engine/planning/untouched_daily_plan_composer.dart';

void main() {
  final evaluatedAt = DateTime.utc(2026, 8, 27);

  const rankedNormalTasks = [
    SubjectPlanTask(
      subjectId: 'mathematics',
      task: StudyTask(
        topicId: 'a',
        type: StudyTaskType.repair,
        sourceTopicId: 'a',
      ),
    ),
    SubjectPlanTask(
      subjectId: 'physics',
      task: StudyTask(
        topicId: 'b',
        type: StudyTaskType.practice,
        sourceTopicId: 'b',
      ),
    ),
    SubjectPlanTask(
      subjectId: 'chemistry',
      task: StudyTask(
        topicId: 'c',
        type: StudyTaskType.measurement,
        sourceTopicId: 'c',
      ),
    ),
    SubjectPlanTask(
      subjectId: 'biology',
      task: StudyTask(
        topicId: 'd',
        type: StudyTaskType.progress,
        sourceTopicId: 'd',
      ),
    ),
    SubjectPlanTask(
      subjectId: 'turkish',
      task: StudyTask(
        topicId: 'e',
        type: StudyTaskType.progress,
        sourceTopicId: 'e',
      ),
    ),
  ];

  DailyReinforcementCandidate subjectCandidate({
    required String id,
    required DateTime dueAt,
    double currentImportance = 0.5,
  }) {
    return DailyReinforcementCandidate(
      id: id,
      dueAt: dueAt,
      currentImportance: currentImportance,
      task: const SubjectReinforcementTask(
        subjectId: 'mathematics',
        type: SubjectReinforcementTaskType.branchReinforcement,
      ),
    );
  }

  group('composeUntouchedDailyPlan', () {
    test('keeps four normal tasks when no reinforcement is due', () {
      final draft = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [
          subjectCandidate(
            id: 'future',
            dueAt: evaluatedAt.add(const Duration(days: 1)),
          ),
        ],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.reinforcement, isNull);
      expect(
        draft.normalSubjectTasks.map((plannedTask) => plannedTask.subjectId),
        ['mathematics', 'physics', 'chemistry', 'biology'],
      );
      expect(draft.normalRoute.tasks.map((task) => task.topicId), [
        'a',
        'b',
        'c',
        'd',
      ]);
      expect(draft.taskCount, 4);
    });

    test('reserves one of four slots for a due reinforcement', () {
      final due = subjectCandidate(id: 'due', dueAt: evaluatedAt);

      final draft = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [due],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.reinforcement, same(due));
      expect(draft.normalRoute.tasks.map((task) => task.topicId), [
        'a',
        'b',
        'c',
      ]);
      expect(draft.taskCount, 4);
      expect(rankedNormalTasks, hasLength(5));
    });

    test('selects only the oldest due reinforcement', () {
      final newer = subjectCandidate(
        id: 'newer',
        dueAt: evaluatedAt.subtract(const Duration(days: 2)),
      );
      final oldest = DailyReinforcementCandidate(
        id: 'oldest',
        dueAt: evaluatedAt.subtract(const Duration(days: 5)),
        currentImportance: 0.1,
        task: const TytSocialReinforcementTask(),
      );

      final draft = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [newer, oldest],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.reinforcement, same(oldest));
      expect(draft.taskCount, 4);
    });

    test('uses higher current importance when due dates match', () {
      final lowerImportance = subjectCandidate(
        id: 'lower',
        dueAt: evaluatedAt,
        currentImportance: 0.4,
      );
      final higherImportance = subjectCandidate(
        id: 'higher',
        dueAt: evaluatedAt,
        currentImportance: 0.9,
      );

      final draft = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [lowerImportance, higherImportance],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.reinforcement, same(higherImportance));
    });

    test('uses lexical id as the final deterministic tie-break', () {
      final beta = subjectCandidate(
        id: 'beta',
        dueAt: evaluatedAt,
        currentImportance: 0.8,
      );
      final alpha = subjectCandidate(
        id: 'alpha',
        dueAt: evaluatedAt,
        currentImportance: 0.8,
      );

      final first = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [beta, alpha],
        evaluatedAt: evaluatedAt,
      );
      final second = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [alpha, beta],
        evaluatedAt: evaluatedAt,
      );

      expect(first.reinforcement, same(alpha));
      expect(second.reinforcement, same(alpha));
    });

    test('keeps bridge and target together within remaining slots', () {
      const routeWithBridgeTasks = [
        SubjectPlanTask(
          subjectId: 'mathematics',
          task: StudyTask(
            topicId: 'a',
            type: StudyTaskType.repair,
            sourceTopicId: 'a',
          ),
        ),
        SubjectPlanTask(
          subjectId: 'mathematics',
          task: StudyTask(
            topicId: 'bridge',
            type: StudyTaskType.bridge,
            sourceTopicId: 'target',
          ),
        ),
        SubjectPlanTask(
          subjectId: 'mathematics',
          task: StudyTask(
            topicId: 'target',
            type: StudyTaskType.progress,
            sourceTopicId: 'target',
          ),
        ),
        SubjectPlanTask(
          subjectId: 'physics',
          task: StudyTask(
            topicId: 'later',
            type: StudyTaskType.practice,
            sourceTopicId: 'later',
          ),
        ),
      ];

      final draft = composeUntouchedDailyPlan(
        rankedNormalTasks: routeWithBridgeTasks,
        reinforcementCandidates: [
          subjectCandidate(id: 'due', dueAt: evaluatedAt),
        ],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.normalRoute.tasks.map((task) => task.topicId), [
        'a',
        'bridge',
        'target',
      ]);
      expect(
        draft.normalSubjectTasks.map((plannedTask) => plannedTask.subjectId),
        ['mathematics', 'mathematics', 'mathematics'],
      );
      expect(draft.taskCount, 4);
    });
  });
}
