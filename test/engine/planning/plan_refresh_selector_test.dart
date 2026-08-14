import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/plan_task_state.dart';
import 'package:rota_app/engine/planning/plan_refresh_selector.dart';

void main() {
  PlanTaskState task(
    String topicId, {
    PlanTaskOwner owner = PlanTaskOwner.coach,
    bool wasTouchedByStudent = false,
  }) {
    return PlanTaskState(
      topicId: topicId,
      owner: owner,
      wasTouchedByStudent: wasTouchedByStudent,
    );
  }

  group('selectRefreshedPlanTasks', () {
    test('untouched draft may grow up to maxTasks', () {
      final result = selectRefreshedPlanTasks(
        previousTasks: [
          task('a'),
          task('b'),
        ],
        refreshedCandidates: [
          task('a'),
          task('b'),
          task('c'),
          task('d'),
        ],
        lifecycle: PlanLifecycle.draftUntouched,
        config: const PlanRefreshSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result, hasLength(4));

      expect(
        result.map((task) => task.topicId),
        ['a', 'b', 'c', 'd'],
      );
    });

    test('untouched draft still respects absolute four-task ceiling', () {
      final result = selectRefreshedPlanTasks(
        previousTasks: [
          task('a'),
          task('b'),
        ],
        refreshedCandidates: [
          task('a'),
          task('b'),
          task('c'),
          task('d'),
          task('e'),
        ],
        lifecycle: PlanLifecycle.draftUntouched,
        config: const PlanRefreshSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result, hasLength(4));

      expect(
        result.map((task) => task.topicId),
        ['a', 'b', 'c', 'd'],
      );
    });

    test(
      'student-modified draft cannot grow beyond previous task count',
      () {
        final result = selectRefreshedPlanTasks(
          previousTasks: [
            task('a'),
            task('b'),
          ],
          refreshedCandidates: [
            task('a'),
            task('b'),
            task('c'),
            task('d'),
          ],
          lifecycle: PlanLifecycle.draftStudentModified,
          config: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        );

        expect(result, hasLength(2));

        expect(
          result.map((task) => task.topicId),
          ['a', 'b'],
        );
      },
    );

    test(
      'student-modified draft can shrink when fewer refreshed tasks remain',
      () {
        final result = selectRefreshedPlanTasks(
          previousTasks: [
            task('a'),
            task('b'),
            task('c'),
          ],
          refreshedCandidates: [
            task('a'),
            task('d'),
          ],
          lifecycle: PlanLifecycle.draftStudentModified,
          config: const PlanRefreshSelectionConfig(
            maxTasks: 4,
          ),
        );

        expect(result, hasLength(2));

        expect(
          result.map((task) => task.topicId),
          ['a', 'd'],
        );
      },
    );

    test('active plan ignores refreshed candidates', () {
      final previousTasks = [
        task(
          'a',
          owner: PlanTaskOwner.student,
        ),
        task(
          'b',
          owner: PlanTaskOwner.coach,
          wasTouchedByStudent: true,
        ),
      ];

      final result = selectRefreshedPlanTasks(
        previousTasks: previousTasks,
        refreshedCandidates: [
          task('x'),
          task('y'),
          task('z'),
        ],
        lifecycle: PlanLifecycle.active,
        config: const PlanRefreshSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result, hasLength(2));
      expect(result[0].topicId, 'a');
      expect(result[1].topicId, 'b');
    });

    test('configured lower capacity also constrains untouched draft', () {
      final result = selectRefreshedPlanTasks(
        previousTasks: [
          task('a'),
        ],
        refreshedCandidates: [
          task('a'),
          task('b'),
          task('c'),
        ],
        lifecycle: PlanLifecycle.draftUntouched,
        config: const PlanRefreshSelectionConfig(
          maxTasks: 2,
        ),
      );

      expect(result, hasLength(2));

      expect(
        result.map((task) => task.topicId),
        ['a', 'b'],
      );
    });

    test('same input produces deterministic selection', () {
      final previousTasks = [
        task('a'),
        task('b'),
      ];

      final refreshedCandidates = [
        task('c'),
        task('d'),
        task('e'),
      ];

      final first = selectRefreshedPlanTasks(
        previousTasks: previousTasks,
        refreshedCandidates: refreshedCandidates,
        lifecycle: PlanLifecycle.draftStudentModified,
        config: const PlanRefreshSelectionConfig(
          maxTasks: 4,
        ),
      );

      final second = selectRefreshedPlanTasks(
        previousTasks: previousTasks,
        refreshedCandidates: refreshedCandidates,
        lifecycle: PlanLifecycle.draftStudentModified,
        config: const PlanRefreshSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(first.length, second.length);

      for (var i = 0; i < first.length; i++) {
        expect(first[i].topicId, second[i].topicId);
      }
    });
  });
}