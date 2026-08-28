import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_study_route.dart';
import 'package:rota_app/engine/planning/weekly_deficit_subject_selector.dart';

void main() {
  SubjectStudyRoute route(String subjectId, {bool hasTask = true}) {
    return SubjectStudyRoute(
      subjectId: subjectId,
      route: StudyRoute(
        tasks: hasTask
            ? [
                StudyTask(
                  topicId: '$subjectId-topic',
                  type: StudyTaskType.practice,
                  sourceTopicId: '$subjectId-topic',
                ),
              ]
            : const [],
      ),
    );
  }

  group('selectNextSubjectByWeeklyDeficit', () {
    test('selects the greatest next-slot deficit', () {
      final mathematics = route('mathematics');
      final physics = route('physics');

      final selected = selectNextSubjectByWeeklyDeficit(
        subjectRoutes: [mathematics, physics],
        targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
        allocatedSlotsBySubject: const {'mathematics': 1, 'physics': 0},
      );

      expect(selected, same(physics));
    });

    test('skips subjects without an eligible route task', () {
      final mathematics = route('mathematics', hasTask: false);
      final physics = route('physics');

      final selected = selectNextSubjectByWeeklyDeficit(
        subjectRoutes: [mathematics, physics],
        targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
        allocatedSlotsBySubject: const {},
      );

      expect(selected, same(physics));
    });

    test('uses subject id as the deterministic deficit tie-breaker', () {
      final physics = route('physics');
      final chemistry = route('chemistry');

      final selected = selectNextSubjectByWeeklyDeficit(
        subjectRoutes: [physics, chemistry],
        targetWeightsBySubject: const {'physics': 0.50, 'chemistry': 0.50},
        allocatedSlotsBySubject: const {},
      );

      expect(selected, same(chemistry));
    });

    test('tracks the target distribution across sequential slots', () {
      const targetWeights = {
        'mathematics': 0.371,
        'physics': 0.140,
        'turkish': 0.130,
        'chemistry': 0.124,
        'biology': 0.122,
        'history': 0.028,
        'geography': 0.028,
        'philosophy': 0.028,
        'religion': 0.028,
      };
      final routes = targetWeights.keys.map(route).toList();
      final allocations = <String, int>{};

      for (var slot = 0; slot < 28; slot++) {
        final selected = selectNextSubjectByWeeklyDeficit(
          subjectRoutes: routes,
          targetWeightsBySubject: targetWeights,
          allocatedSlotsBySubject: allocations,
        );

        allocations.update(
          selected!.subjectId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      expect(allocations, {
        'mathematics': 10,
        'physics': 4,
        'turkish': 4,
        'chemistry': 3,
        'biology': 3,
        'geography': 1,
        'history': 1,
        'philosophy': 1,
        'religion': 1,
      });
    });

    test('returns null when no subject has an eligible route task', () {
      final selected = selectNextSubjectByWeeklyDeficit(
        subjectRoutes: [route('mathematics', hasTask: false)],
        targetWeightsBySubject: const {'mathematics': 1.0},
        allocatedSlotsBySubject: const {},
      );

      expect(selected, isNull);
    });
  });
}
