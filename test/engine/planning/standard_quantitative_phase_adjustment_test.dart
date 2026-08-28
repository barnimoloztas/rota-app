import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_study_route.dart';
import 'package:rota_app/engine/planning/standard_quantitative_phase_adjustment.dart';
import 'package:rota_app/engine/planning/standard_quantitative_subject_base_weights.dart';
import 'package:rota_app/engine/planning/weekly_deficit_subject_selector.dart';

void main() {
  const socialSubjectIds = {'history', 'geography', 'philosophy', 'religion'};

  SubjectStudyRoute route(String subjectId) {
    return SubjectStudyRoute(
      subjectId: subjectId,
      route: StudyRoute(
        tasks: [
          StudyTask(
            topicId: '$subjectId-topic',
            type: StudyTaskType.practice,
            sourceTopicId: '$subjectId-topic',
          ),
        ],
      ),
    );
  }

  group('standardQuantitativeTargetWeights', () {
    for (final phaseAndMultiplier in [
      (PreparationPhase.early, 0.35),
      (PreparationPhase.middle, 0.60),
    ]) {
      final (phase, socialMultiplier) = phaseAndMultiplier;

      test('applies the accepted social multiplier for ${phase.name}', () {
        final baseWeights = standardQuantitativeSubjectBaseWeights();
        final targetWeights = standardQuantitativeTargetWeights(phase: phase);
        final expectedTotal = baseWeights.entries.fold(
          0.0,
          (total, entry) =>
              total +
              entry.value *
                  (socialSubjectIds.contains(entry.key)
                      ? socialMultiplier
                      : 1.0),
        );

        for (final entry in baseWeights.entries) {
          final expectedWeight =
              entry.value *
              (socialSubjectIds.contains(entry.key) ? socialMultiplier : 1.0) /
              expectedTotal;

          expect(targetWeights[entry.key], closeTo(expectedWeight, 1e-12));
        }

        expect(
          targetWeights.values.fold(0.0, (total, weight) => total + weight),
          closeTo(1.0, 1e-12),
        );
      });
    }

    test('keeps standard Base Weights in the late phase', () {
      expect(
        standardQuantitativeTargetWeights(phase: PreparationPhase.late),
        standardQuantitativeSubjectBaseWeights(),
      );
    });

    test('produces the accepted social contact counts across 28 slots', () {
      for (final phaseAndExpectedCount in [
        (PreparationPhase.early, 1),
        (PreparationPhase.middle, 2),
        (PreparationPhase.late, 4),
      ]) {
        final (phase, expectedSocialCount) = phaseAndExpectedCount;
        final targetWeights = standardQuantitativeTargetWeights(phase: phase);
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

        final socialCount = socialSubjectIds.fold(
          0,
          (total, subjectId) => total + (allocations[subjectId] ?? 0),
        );

        expect(socialCount, expectedSocialCount, reason: phase.name);
      }
    });

    test('returns an unmodifiable target weight map', () {
      final targetWeights = standardQuantitativeTargetWeights(
        phase: PreparationPhase.early,
      );

      expect(() => targetWeights['mathematics'] = 1.0, throwsUnsupportedError);
    });
  });
}
