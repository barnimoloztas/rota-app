import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_study_route.dart';
import 'package:rota_app/engine/planning/subject_plan_task_mapper.dart';

void main() {
  test('preserves subject and task order while flattening route segments', () {
    const bridge = StudyTask(
      topicId: 'functions',
      type: StudyTaskType.bridge,
      sourceTopicId: 'limits',
    );
    const target = StudyTask(
      topicId: 'limits',
      type: StudyTaskType.progress,
      sourceTopicId: 'limits',
    );
    const physicsTask = StudyTask(
      topicId: 'vectors',
      type: StudyTaskType.practice,
      sourceTopicId: 'vectors',
    );
    const segments = [
      SubjectStudyRoute(
        subjectId: 'mathematics',
        route: StudyRoute(tasks: [bridge, target]),
      ),
      SubjectStudyRoute(
        subjectId: 'physics',
        route: StudyRoute(tasks: [physicsTask]),
      ),
    ];

    final planTasks = subjectPlanTasksFromRoutes(segments);

    expect(planTasks.map((planTask) => planTask.subjectId), [
      'mathematics',
      'mathematics',
      'physics',
    ]);
    expect(planTasks[0].task, same(bridge));
    expect(planTasks[1].task, same(target));
    expect(planTasks[2].task, same(physicsTask));
  });

  test('returns an empty list for empty route input', () {
    final planTasks = subjectPlanTasksFromRoutes(const []);

    expect(planTasks, isEmpty);
  });
}
