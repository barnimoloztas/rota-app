import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_task_state.dart';

void main() {
  group('PlanTaskState', () {
    test('student-owned task is protected from refresh', () {
      const task = PlanTaskState(
        topicId: 'fonksiyonlar',
        owner: PlanTaskOwner.student,
        wasTouchedByStudent: false,
      );

      expect(task.isProtectedFromRefresh, isTrue);
    });

    test('coach-owned untouched task is not protected from refresh', () {
      const task = PlanTaskState(
        topicId: 'turev',
        owner: PlanTaskOwner.coach,
        wasTouchedByStudent: false,
      );

      expect(task.isProtectedFromRefresh, isFalse);
    });

    test('coach-owned touched task becomes protected from refresh', () {
      const task = PlanTaskState(
        topicId: 'integral',
        owner: PlanTaskOwner.coach,
        wasTouchedByStudent: true,
      );

      expect(task.isProtectedFromRefresh, isTrue);
    });

    test('student-owned task remains protected after touch', () {
      const task = PlanTaskState(
        topicId: 'trigonometri',
        owner: PlanTaskOwner.student,
        wasTouchedByStudent: true,
      );

      expect(task.isProtectedFromRefresh, isTrue);
    });
  });
}