import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/practice_signal.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/planning/daily_plan_activation.dart';
import 'package:rota_app/engine/planning/daily_plan_progress_completion.dart';
import 'package:rota_app/engine/signal/practice_signal_generator.dart';

void main() {
  test('active Progress completion enables P1 without changing allocation', () {
    final completedAt = DateTime.utc(2026, 8, 29);
    final plan = DailyPlanDraft(
      normalSubjectTasks: const [
        SubjectPlanTask(
          subjectId: 'mathematics',
          task: StudyTask(
            topicId: 'functions',
            type: StudyTaskType.progress,
            sourceTopicId: 'functions',
          ),
        ),
      ],
      reinforcement: null,
    );
    const incompleteLifecycle = TopicLearningLifecycle(
      topicId: 'functions',
      progressCompletedAt: null,
      completedInitialPracticeCount: 0,
      firstPracticeCompletedAt: null,
      lastPracticeCompletedAt: null,
    );

    final activation = activateDailyPlan(
      lifecycle: PlanLifecycle.draftUntouched,
      dailyPlan: plan,
      planPhase: PreparationPhase.early,
      allocationPhase: PreparationPhase.early,
      allocatedSlotsBySubject: const {},
    );
    final completion = completeDailyPlanProgress(
      planLifecycle: activation.lifecycle,
      dailyPlan: plan,
      academicTaskIndex: 0,
      completedAcademicTaskIndexes: const {},
      topicLifecycle: incompleteLifecycle,
      completedAt: completedAt,
    );

    final practiceSignal = generatePracticeSignals(
      lifecycles: [completion.topicLifecycle],
      evaluatedAt: completedAt,
    ).single;

    expect(activation.allocatedSlotsBySubject, {'mathematics': 1});
    expect(completion.didComplete, isTrue);
    expect(completion.completedAcademicTaskIndexes, {0});
    expect(completion.topicLifecycle.progressCompletedAt, completedAt);
    expect(practiceSignal.topicId, 'functions');
    expect(practiceSignal.reason, PracticeSignalReason.initialPractice);
    expect(activation.allocatedSlotsBySubject, {'mathematics': 1});
  });
}
