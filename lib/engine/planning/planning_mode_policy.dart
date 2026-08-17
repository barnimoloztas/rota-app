import '../../domain/planning_mode.dart';
import '../../domain/study_candidate.dart';

class PlanningModePolicy {
  const PlanningModePolicy({
    required this.mode,
    required this.emphasizedSources,
    required this.deemphasizedSources,
    required this.deemphasizeBridgeProgress,
    required this.requiresAvoidanceAdaptation,
  });

  final PlanningMode mode;

  final Set<CandidateSource> emphasizedSources;

  final Set<CandidateSource> deemphasizedSources;

  final bool deemphasizeBridgeProgress;

  final bool requiresAvoidanceAdaptation;
}

PlanningModePolicy planningModePolicyFor(
  PlanningMode mode,
) {
  switch (mode) {
    case PlanningMode.normal:
      return const PlanningModePolicy(
        mode: PlanningMode.normal,
        emphasizedSources: {
          CandidateSource.repair,
        },
        deemphasizedSources: {},
        deemphasizeBridgeProgress: false,
        requiresAvoidanceAdaptation: false,
      );

    case PlanningMode.preExam:
      return const PlanningModePolicy(
        mode: PlanningMode.preExam,
        emphasizedSources: {
          CandidateSource.measurement,
        },
        deemphasizedSources: {
          CandidateSource.progress,
        },
        deemphasizeBridgeProgress: true,
        requiresAvoidanceAdaptation: false,
      );

    case PlanningMode.postExam:
      return const PlanningModePolicy(
        mode: PlanningMode.postExam,
        emphasizedSources: {
          CandidateSource.repair,
        },
        deemphasizedSources: {},
        deemphasizeBridgeProgress: false,
        requiresAvoidanceAdaptation: false,
      );

    case PlanningMode.avoidance:
      return const PlanningModePolicy(
        mode: PlanningMode.avoidance,
        emphasizedSources: {},
        deemphasizedSources: {},
        deemphasizeBridgeProgress: false,
        requiresAvoidanceAdaptation: true,
      );
  }
}