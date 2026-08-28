import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';

void main() {
  test('keeps a study task together with its subject', () {
    const task = StudyTask(
      topicId: 'functions',
      type: StudyTaskType.practice,
      sourceTopicId: 'functions',
    );

    const planTask = SubjectPlanTask(subjectId: 'mathematics', task: task);

    expect(planTask.subjectId, 'mathematics');
    expect(planTask.task, same(task));
  });
}
