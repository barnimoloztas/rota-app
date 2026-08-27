import 'reinforcement_task.dart';
import 'subject.dart';

enum SubjectReinforcementTaskType { topicReinforcement, branchReinforcement }

class SubjectReinforcementTask extends ReinforcementTask {
  const SubjectReinforcementTask({required this.subjectId, required this.type})
    : super();

  final SubjectId subjectId;

  final SubjectReinforcementTaskType type;
}
