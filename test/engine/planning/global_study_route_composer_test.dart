import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_study_route.dart';
import 'package:rota_app/engine/planning/global_study_route_composer.dart';
import 'package:rota_app/engine/route/route_selector.dart';

void main() {
  StudyTask task(
    String topicId, {
    StudyTaskType type = StudyTaskType.practice,
    String? sourceTopicId,
  }) {
    return StudyTask(
      topicId: topicId,
      type: type,
      sourceTopicId: sourceTopicId ?? topicId,
    );
  }

  SubjectStudyRoute subjectRoute(String subjectId, List<StudyTask> tasks) {
    return SubjectStudyRoute(
      subjectId: subjectId,
      route: StudyRoute(tasks: tasks),
    );
  }

  List<String> selectedSubjectIds(List<SubjectStudyRoute> segments) {
    return segments.map((segment) => segment.subjectId).toList();
  }

  List<String> selectedTopicIds(List<SubjectStudyRoute> segments) {
    return segments
        .expand((segment) => segment.tasks)
        .map((task) => task.topicId)
        .toList();
  }

  group('composeGlobalStudyRoute', () {
    test('recalculates weekly deficit after every selected task', () {
      final mathematics = subjectRoute('mathematics', [
        task('math-1'),
        task('math-2'),
        task('math-3'),
      ]);
      final physics = subjectRoute('physics', [
        task('physics-1'),
        task('physics-2'),
        task('physics-3'),
      ]);

      final segments = composeGlobalStudyRoute(
        subjectRoutes: [mathematics, physics],
        targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {},
        selectionConfig: const RouteSelectionConfig(maxTasks: 4),
      );

      expect(selectedSubjectIds(segments), [
        'mathematics',
        'physics',
        'mathematics',
        'physics',
      ]);
      expect(selectedTopicIds(segments), [
        'math-1',
        'physics-1',
        'math-2',
        'physics-2',
      ]);
    });

    test('uses existing allocations without mutating the input map', () {
      final allocations = {'mathematics': 1, 'physics': 0};

      final segments = composeGlobalStudyRoute(
        subjectRoutes: [
          subjectRoute('mathematics', [task('math-1')]),
          subjectRoute('physics', [task('physics-1')]),
        ],
        targetWeightsBySubject: const {'mathematics': 0.60, 'physics': 0.40},
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: allocations,
        selectionConfig: const RouteSelectionConfig(maxTasks: 2),
      );

      expect(selectedSubjectIds(segments), ['physics', 'mathematics']);
      expect(allocations, {'mathematics': 1, 'physics': 0});
    });

    test('keeps bridge and target together as a two-slot unit', () {
      final segments = composeGlobalStudyRoute(
        subjectRoutes: [
          subjectRoute('mathematics', [
            task(
              'functions',
              type: StudyTaskType.bridge,
              sourceTopicId: 'limits',
            ),
            task('limits', type: StudyTaskType.progress),
            task('derivatives'),
          ]),
          subjectRoute('physics', [task('vectors')]),
        ],
        targetWeightsBySubject: const {'mathematics': 0.80, 'physics': 0.20},
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {},
        selectionConfig: const RouteSelectionConfig(maxTasks: 3),
      );

      expect(selectedSubjectIds(segments), ['mathematics', 'physics']);
      expect(segments.first.tasks, hasLength(2));
      expect(selectedTopicIds(segments), ['functions', 'limits', 'vectors']);
    });

    test('selects another subject when a bridge pair does not fit', () {
      final segments = composeGlobalStudyRoute(
        subjectRoutes: [
          subjectRoute('mathematics', [
            task(
              'functions',
              type: StudyTaskType.bridge,
              sourceTopicId: 'limits',
            ),
            task('limits', type: StudyTaskType.progress),
          ]),
          subjectRoute('physics', [task('vectors')]),
        ],
        targetWeightsBySubject: const {'mathematics': 0.80, 'physics': 0.20},
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {},
        selectionConfig: const RouteSelectionConfig(maxTasks: 1),
      );

      expect(selectedSubjectIds(segments), ['physics']);
      expect(selectedTopicIds(segments), ['vectors']);
    });

    test('leaves capacity unused rather than splitting a bridge pair', () {
      final mathematics = subjectRoute('mathematics', [
        task('functions', type: StudyTaskType.bridge, sourceTopicId: 'limits'),
        task('limits', type: StudyTaskType.progress),
      ]);

      final segments = composeGlobalStudyRoute(
        subjectRoutes: [mathematics],
        targetWeightsBySubject: const {'mathematics': 1.0},
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {},
        selectionConfig: const RouteSelectionConfig(maxTasks: 1),
      );

      expect(segments, isEmpty);
      expect(mathematics.tasks, hasLength(2));
    });
  });
}
