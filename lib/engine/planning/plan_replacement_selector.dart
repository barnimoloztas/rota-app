import '../../domain/study_route.dart';

StudyTask? selectReplacementTask({
  required StudyTask taskToReplace,
  required Iterable<StudyTask> rankedRefreshedTasks,
  required Iterable<StudyTask> protectedTasks,
}) {
  final protectedTopicIds = protectedTasks
      .map((task) => task.topicId)
      .toSet();

  for (final candidateTask in rankedRefreshedTasks) {
    if (candidateTask.topicId == taskToReplace.topicId &&
        candidateTask.type == taskToReplace.type) {
      continue;
    }

    if (protectedTopicIds.contains(candidateTask.topicId)) {
      continue;
    }

    return candidateTask;
  }

  return null;
}