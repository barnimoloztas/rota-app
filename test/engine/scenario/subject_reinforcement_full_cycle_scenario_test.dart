import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_completion_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_task_generator.dart';

void main() {
  group('subject reinforcement full cycle scenario', () {
    test(
      'moves from R1 through R3 and then continues with weekly branch reinforcement',
      () {
        var lifecycle = SubjectReinforcementLifecycle(
          subjectId: 'mathematics',
          startedAt: DateTime.utc(2026, 8, 1),
          completedInitialReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        );

        // First week is intentionally free of topic reinforcement.
        final firstWeekTask = generateSubjectReinforcementTask(
          lifecycle: lifecycle,
          evaluatedAt: DateTime.utc(2026, 8, 8),
        );

        expect(firstWeekTask, isNull);

        // R1 becomes due two weeks after the lifecycle starts.
        final r1 = generateSubjectReinforcementTask(
          lifecycle: lifecycle,
          evaluatedAt: DateTime.utc(2026, 8, 15),
        );

        expect(r1, isNotNull);
        expect(
          r1!.type,
          SubjectReinforcementTaskType.topicReinforcement,
        );

        lifecycle = completeSubjectReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 15),
        );

        expect(
          lifecycle.completedInitialReinforcementCount,
          1,
        );

        // R2 becomes due one week after R1 completion.
        final r2 = generateSubjectReinforcementTask(
          lifecycle: lifecycle,
          evaluatedAt: DateTime.utc(2026, 8, 22),
        );

        expect(r2, isNotNull);
        expect(
          r2!.type,
          SubjectReinforcementTaskType.topicReinforcement,
        );

        lifecycle = completeSubjectReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 22),
        );

        expect(
          lifecycle.completedInitialReinforcementCount,
          2,
        );

        // R3 becomes due one week after R2 completion.
        final r3 = generateSubjectReinforcementTask(
          lifecycle: lifecycle,
          evaluatedAt: DateTime.utc(2026, 8, 29),
        );

        expect(r3, isNotNull);
        expect(
          r3!.type,
          SubjectReinforcementTaskType.topicReinforcement,
        );

        lifecycle = completeSubjectReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 29),
        );

        expect(
          lifecycle.completedInitialReinforcementCount,
          3,
        );

        // After R3, the weekly reinforcement becomes branch reinforcement.
        final firstBranchReinforcement =
            generateSubjectReinforcementTask(
          lifecycle: lifecycle,
          evaluatedAt: DateTime.utc(2026, 9, 5),
        );

        expect(firstBranchReinforcement, isNotNull);
        expect(
          firstBranchReinforcement!.type,
          SubjectReinforcementTaskType.branchReinforcement,
        );

        lifecycle = completeSubjectReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 9, 5),
        );

        // Initial reinforcement count stays capped at 3.
        expect(
          lifecycle.completedInitialReinforcementCount,
          3,
        );

        // Branch reinforcement continues weekly.
        final secondBranchReinforcement =
            generateSubjectReinforcementTask(
          lifecycle: lifecycle,
          evaluatedAt: DateTime.utc(2026, 9, 12),
        );

        expect(secondBranchReinforcement, isNotNull);
        expect(
          secondBranchReinforcement!.type,
          SubjectReinforcementTaskType.branchReinforcement,
        );
      },
    );
  });
}