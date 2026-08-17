import 'subject_reinforcement_lifecycle.dart';

enum SubjectReinforcementTaskType {
  topicReinforcement,
  branchReinforcement,
}

class SubjectReinforcementTask {
  const SubjectReinforcementTask({
    required this.subjectId,
    required this.type,
  });

  final SubjectId subjectId;

  final SubjectReinforcementTaskType type;
}