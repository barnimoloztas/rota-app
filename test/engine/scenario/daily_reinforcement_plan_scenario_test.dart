import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_task.dart';
import 'package:rota_app/engine/planning/untouched_daily_plan_composer.dart';
import 'package:rota_app/engine/reinforcement/daily_reinforcement_candidate_generator.dart';

void main() {
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
  ];

  group('daily reinforcement plan scenario', () {
    test('keeps four normal tasks before real reinforcements are due', () {
      final evaluatedAt = DateTime.utc(2026, 8, 14);
      final subjectCandidate = generateSubjectDailyReinforcementCandidate(
        lifecycle: SubjectReinforcementLifecycle(
          subjectId: 'mathematics',
          startedAt: DateTime.utc(2026, 8, 1),
          completedInitialReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: evaluatedAt,
        currentImportance: 0.8,
      );
      final socialCandidate = generateTytSocialDailyReinforcementCandidate(
        lifecycle: TytSocialReinforcementLifecycle(
          startedAt: DateTime.utc(2026, 8, 1),
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: evaluatedAt,
        currentImportance: 0.4,
      );

      final draft = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [
          subjectCandidate,
          socialCandidate,
        ].whereType<DailyReinforcementCandidate>(),
        evaluatedAt: evaluatedAt,
      );

      expect(subjectCandidate, isNull);
      expect(socialCandidate, isNull);
      expect(draft.reinforcement, isNull);
      expect(draft.taskCount, 4);
    });

    test('places the oldest real reinforcement before normal tasks', () {
      final evaluatedAt = DateTime.utc(2026, 10, 1);
      final subjectCandidate = generateSubjectDailyReinforcementCandidate(
        lifecycle: SubjectReinforcementLifecycle(
          subjectId: 'mathematics',
          startedAt: DateTime.utc(2026, 8, 1),
          completedInitialReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: evaluatedAt,
        currentImportance: 0.2,
      );
      final socialCandidate = generateTytSocialDailyReinforcementCandidate(
        lifecycle: TytSocialReinforcementLifecycle(
          startedAt: DateTime.utc(2026, 8, 1),
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: evaluatedAt,
        currentImportance: 0.9,
      );

      expect(subjectCandidate, isNotNull);
      final dueSubjectCandidate = subjectCandidate!;
      expect(dueSubjectCandidate.id, 'subject:mathematics');
      expect(dueSubjectCandidate.dueAt, DateTime.utc(2026, 8, 15));
      expect(dueSubjectCandidate.task, isA<SubjectReinforcementTask>());
      expect(
        (dueSubjectCandidate.task as SubjectReinforcementTask).type,
        SubjectReinforcementTaskType.topicReinforcement,
      );

      expect(socialCandidate, isNotNull);
      final dueSocialCandidate = socialCandidate!;
      expect(dueSocialCandidate.id, 'scope:tyt-social');
      expect(dueSocialCandidate.dueAt, DateTime.utc(2026, 9, 15));
      expect(dueSocialCandidate.task, isA<TytSocialReinforcementTask>());

      final draft = composeUntouchedDailyPlan(
        rankedNormalTasks: rankedNormalTasks,
        reinforcementCandidates: [dueSocialCandidate, dueSubjectCandidate],
        evaluatedAt: evaluatedAt,
      );

      expect(draft.reinforcement, same(dueSubjectCandidate));
      expect(draft.normalRoute.tasks, hasLength(3));
      expect(draft.taskCount, 4);
    });
  });
}
