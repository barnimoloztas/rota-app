import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/planning_mode.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/planning/planning_mode_policy.dart';

void main() {
  group('planningModePolicyFor', () {
    test('normal mode emphasizes repair without suppressing progress', () {
      final policy = planningModePolicyFor(
        PlanningMode.normal,
      );

      expect(policy.mode, PlanningMode.normal);

      expect(
        policy.emphasizedSources,
        contains(CandidateSource.repair),
      );

      expect(
        policy.deemphasizedSources,
        isEmpty,
      );

      expect(
        policy.deemphasizeBridgeProgress,
        isFalse,
      );

      expect(
        policy.requiresAvoidanceAdaptation,
        isFalse,
      );
    });

    test(
      'preExam emphasizes measurement',
      () {
        final policy = planningModePolicyFor(
          PlanningMode.preExam,
        );

        expect(
          policy.emphasizedSources,
          {
            CandidateSource.measurement,
          },
        );
      },
    );

    test(
      'preExam deemphasizes progress and bridge-heavy progress',
      () {
        final policy = planningModePolicyFor(
          PlanningMode.preExam,
        );

        expect(
          policy.deemphasizedSources,
          contains(CandidateSource.progress),
        );

        expect(
          policy.deemphasizeBridgeProgress,
          isTrue,
        );
      },
    );

    test('postExam emphasizes repair', () {
      final policy = planningModePolicyFor(
        PlanningMode.postExam,
      );

      expect(
        policy.emphasizedSources,
        contains(CandidateSource.repair),
      );

      expect(
        policy.deemphasizedSources,
        isEmpty,
      );

      expect(
        policy.deemphasizeBridgeProgress,
        isFalse,
      );
    });

    test(
      'avoidance requires a later adaptation step',
      () {
        final policy = planningModePolicyFor(
          PlanningMode.avoidance,
        );

        expect(
          policy.requiresAvoidanceAdaptation,
          isTrue,
        );

        expect(
          policy.emphasizedSources,
          isEmpty,
        );

        expect(
          policy.deemphasizedSources,
          isEmpty,
        );
      },
    );

    test('returns deterministic policy for every planning mode', () {
      for (final mode in PlanningMode.values) {
        final first = planningModePolicyFor(mode);
        final second = planningModePolicyFor(mode);

        expect(first.mode, second.mode);

        expect(
          first.emphasizedSources,
          second.emphasizedSources,
        );

        expect(
          first.deemphasizedSources,
          second.deemphasizedSources,
        );

        expect(
          first.deemphasizeBridgeProgress,
          second.deemphasizeBridgeProgress,
        );

        expect(
          first.requiresAvoidanceAdaptation,
          second.requiresAvoidanceAdaptation,
        );
      }
    });
  });
}