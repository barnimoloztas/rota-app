import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_task_state.dart';
import 'package:rota_app/engine/planning/plan_refresh_evaluator.dart';

void main() {
  group('evaluatePlanRefresh', () {
    test('keeps student-owned task even when new data invalidates it', () {
      const task = PlanTaskState(
        topicId: 'fonksiyonlar',
        owner: PlanTaskOwner.student,
        wasTouchedByStudent: false,
      );

      final result = evaluatePlanRefresh(
        task: task,
        invalidatedByNewData: true,
      );

      expect(result.decision, PlanRefreshDecision.keep);
      expect(result.invalidatedByNewData, isTrue);
    });

    test('keeps coach-owned task after student touched it', () {
      const task = PlanTaskState(
        topicId: 'turev',
        owner: PlanTaskOwner.coach,
        wasTouchedByStudent: true,
      );

      final result = evaluatePlanRefresh(
        task: task,
        invalidatedByNewData: true,
      );

      expect(result.decision, PlanRefreshDecision.keep);
    });

    test(
      'replaces untouched coach-owned task when new data invalidates it',
      () {
        const task = PlanTaskState(
          topicId: 'integral',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: false,
        );

        final result = evaluatePlanRefresh(
          task: task,
          invalidatedByNewData: true,
        );

        expect(result.decision, PlanRefreshDecision.replace);
        expect(result.invalidatedByNewData, isTrue);
      },
    );

    test(
      'keeps untouched coach-owned task when new data does not invalidate it',
      () {
        const task = PlanTaskState(
          topicId: 'trigonometri',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: false,
        );

        final result = evaluatePlanRefresh(
          task: task,
          invalidatedByNewData: false,
        );

        expect(result.decision, PlanRefreshDecision.keep);
        expect(result.invalidatedByNewData, isFalse);
      },
    );
  });
}