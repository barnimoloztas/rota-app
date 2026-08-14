import 'topic.dart';

enum PlanTaskOwner {
  coach,
  student,
}

class PlanTaskState {
  const PlanTaskState({
    required this.topicId,
    required this.owner,
    required this.wasTouchedByStudent,
  });

  /// Topic represented by this plan task.
  final TopicId topicId;

  /// Who originally placed the task into the plan.
  final PlanTaskOwner owner;

  /// Whether the student has interacted with this task after it entered
  /// the plan.
  ///
  /// Once true, refresh logic must treat the task as protected.
  final bool wasTouchedByStudent;

  /// Student-owned tasks are protected by definition.
  ///
  /// Coach-owned tasks become protected once the student touches them.
  bool get isProtectedFromRefresh {
    return owner == PlanTaskOwner.student ||
        wasTouchedByStudent;
  }
}