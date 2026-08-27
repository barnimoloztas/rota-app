import '../../domain/daily_plan_draft.dart';
import '../../domain/subject_reinforcement_lifecycle.dart';
import '../../domain/tyt_social_reinforcement_lifecycle.dart';
import 'subject_reinforcement_policy.dart';
import 'subject_reinforcement_task_generator.dart';
import 'tyt_social_reinforcement_policy.dart';
import 'tyt_social_reinforcement_task_generator.dart';

DailyReinforcementCandidate? generateSubjectDailyReinforcementCandidate({
  required SubjectReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
  required double currentImportance,
}) {
  final task = generateSubjectReinforcementTask(
    lifecycle: lifecycle,
    evaluatedAt: evaluatedAt,
  );

  if (task == null) {
    return null;
  }

  return DailyReinforcementCandidate(
    id: 'subject:${lifecycle.subjectId}',
    dueAt: subjectReinforcementDueAt(lifecycle: lifecycle),
    currentImportance: currentImportance,
    task: task,
  );
}

DailyReinforcementCandidate? generateTytSocialDailyReinforcementCandidate({
  required TytSocialReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
  required double currentImportance,
}) {
  final task = generateTytSocialReinforcementTask(
    lifecycle: lifecycle,
    evaluatedAt: evaluatedAt,
  );

  if (task == null) {
    return null;
  }

  return DailyReinforcementCandidate(
    id: 'scope:tyt-social',
    dueAt: tytSocialReinforcementDueAt(lifecycle: lifecycle),
    currentImportance: currentImportance,
    task: task,
  );
}
