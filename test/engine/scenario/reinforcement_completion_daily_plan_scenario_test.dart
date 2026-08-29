import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/engine/planning/daily_plan_activation.dart';
import 'package:rota_app/engine/planning/daily_plan_reinforcement_completion.dart';
import 'package:rota_app/engine/reinforcement/daily_reinforcement_candidate_generator.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_policy.dart';

void main() {
  test('repeated active completion does not advance reinforcement twice', () {
    final firstDueAt = DateTime.utc(2026, 8, 15);
    final lifecycle = SubjectReinforcementLifecycle(
      subjectId: 'mathematics',
      startedAt: DateTime.utc(2026, 8, 1),
      completedInitialReinforcementCount: 0,
      lastReinforcementCompletedAt: null,
    );
    final candidate = generateSubjectDailyReinforcementCandidate(
      lifecycle: lifecycle,
      evaluatedAt: firstDueAt,
      currentImportance: 0.8,
    );
    final plan = DailyPlanDraft(
      normalSubjectTasks: const [],
      reinforcement: candidate,
    );
    final activation = activateDailyPlan(
      lifecycle: PlanLifecycle.draftUntouched,
      dailyPlan: plan,
      planPhase: PreparationPhase.early,
      allocationPhase: PreparationPhase.early,
      allocatedSlotsBySubject: const {},
    );

    final firstCompletion = completeDailyPlanSubjectReinforcement(
      planLifecycle: activation.lifecycle,
      dailyPlan: plan,
      reinforcementCompleted: false,
      reinforcementLifecycle: lifecycle,
      completedAt: firstDueAt,
    );
    final repeatedCompletion = completeDailyPlanSubjectReinforcement(
      planLifecycle: activation.lifecycle,
      dailyPlan: plan,
      reinforcementCompleted: firstCompletion.reinforcementCompleted,
      reinforcementLifecycle: firstCompletion.lifecycle,
      completedAt: DateTime.utc(2026, 8, 16),
    );

    expect(candidate, isNotNull);
    expect(activation.allocatedSlotsBySubject, {'mathematics': 1});
    expect(firstCompletion.didComplete, isTrue);
    expect(repeatedCompletion.didComplete, isFalse);
    expect(repeatedCompletion.lifecycle.completedInitialReinforcementCount, 1);
    expect(
      repeatedCompletion.lifecycle.lastReinforcementCompletedAt,
      firstDueAt,
    );
    expect(
      subjectReinforcementDueAt(lifecycle: repeatedCompletion.lifecycle),
      DateTime.utc(2026, 8, 22),
    );
    expect(activation.allocatedSlotsBySubject, {'mathematics': 1});
  });
}
