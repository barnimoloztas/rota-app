import '../../domain/daily_plan_draft.dart';
import '../../domain/plan_lifecycle.dart';
import '../../domain/practice_completion_record.dart';
import '../../domain/study_route.dart';
import '../../domain/topic_learning_lifecycle.dart';
import '../practice/practice_completion_lifecycle.dart';

class DailyPlanPracticeCompletionResult {
  DailyPlanPracticeCompletionResult._({
    required this.topicLifecycle,
    required this.didComplete,
    required this.completionRecord,
    required Set<int> completedAcademicTaskIndexes,
  }) : completedAcademicTaskIndexes = Set<int>.unmodifiable(
         Set<int>.of(completedAcademicTaskIndexes),
       );

  final TopicLearningLifecycle topicLifecycle;

  /// Whether this call completed the planned Practice for the first time.
  final bool didComplete;

  /// The completion record emitted by this call.
  ///
  /// Null means the planned Practice had already been completed, so this call
  /// did not emit another record.
  final PracticeCompletionRecord? completionRecord;

  /// Completed task positions in the frozen active plan.
  ///
  /// Protected subject tasks come first, followed by normal subject tasks.
  final Set<int> completedAcademicTaskIndexes;
}

DailyPlanPracticeCompletionResult completeDailyPlanPractice({
  required PlanLifecycle planLifecycle,
  required DailyPlanDraft dailyPlan,
  required int academicTaskIndex,
  required Set<int> completedAcademicTaskIndexes,
  required TopicLearningLifecycle topicLifecycle,
  required DateTime completedAt,
  int? actualQuestionCount,
  int? correctCount,
  int? wrongCount,
  int? blankCount,
}) {
  if (planLifecycle != PlanLifecycle.active) {
    throw StateError('Only an active daily plan can be completed.');
  }

  final academicTasks = [
    ...dailyPlan.protectedSubjectTasks,
    ...dailyPlan.normalSubjectTasks,
  ];
  RangeError.checkValidIndex(
    academicTaskIndex,
    academicTasks,
    'academicTaskIndex',
  );

  final plannedTask = academicTasks[academicTaskIndex].task;
  if (plannedTask.type != StudyTaskType.practice) {
    throw StateError('The selected daily plan task is not a Practice.');
  }
  if (plannedTask.topicId != topicLifecycle.topicId) {
    throw ArgumentError.value(
      topicLifecycle.topicId,
      'topicLifecycle',
      'must match the selected daily plan task topic',
    );
  }

  if (completedAcademicTaskIndexes.contains(academicTaskIndex)) {
    return DailyPlanPracticeCompletionResult._(
      topicLifecycle: topicLifecycle,
      didComplete: false,
      completionRecord: null,
      completedAcademicTaskIndexes: completedAcademicTaskIndexes,
    );
  }

  final completionRecord = PracticeCompletionRecord(
    topicId: plannedTask.topicId,
    completedAt: completedAt,
    actualQuestionCount: actualQuestionCount,
    correctCount: correctCount,
    wrongCount: wrongCount,
    blankCount: blankCount,
  );

  return DailyPlanPracticeCompletionResult._(
    topicLifecycle: completePractice(
      lifecycle: topicLifecycle,
      completedAt: completedAt,
    ),
    didComplete: true,
    completionRecord: completionRecord,
    completedAcademicTaskIndexes: {
      ...completedAcademicTaskIndexes,
      academicTaskIndex,
    },
  );
}
