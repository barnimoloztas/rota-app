import '../../domain/subject_plan_task.dart';
import '../../domain/subject_study_route.dart';

List<SubjectPlanTask> subjectPlanTasksFromRoutes(
  Iterable<SubjectStudyRoute> subjectRoutes,
) {
  return List<SubjectPlanTask>.unmodifiable(
    subjectRoutes.expand(
      (subjectRoute) => subjectRoute.tasks.map(
        (task) =>
            SubjectPlanTask(subjectId: subjectRoute.subjectId, task: task),
      ),
    ),
  );
}
