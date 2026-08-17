import '../../domain/subject_reinforcement_lifecycle.dart';
import '../../domain/subject_reinforcement_task.dart';
import 'subject_reinforcement_policy.dart';

SubjectReinforcementTask? generateSubjectReinforcementTask({
  required SubjectReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  final evaluation = evaluateSubjectReinforcement(
    lifecycle: lifecycle,
    evaluatedAt: evaluatedAt,
  );

  if (!evaluation.isDue || evaluation.type == null) {
    return null;
  }

  final taskType = switch (evaluation.type!) {
    SubjectReinforcementType.topicReinforcement =>
      SubjectReinforcementTaskType.topicReinforcement,
    SubjectReinforcementType.branchReinforcement =>
      SubjectReinforcementTaskType.branchReinforcement,
  };

  return SubjectReinforcementTask(
    subjectId: lifecycle.subjectId,
    type: taskType,
  );
}