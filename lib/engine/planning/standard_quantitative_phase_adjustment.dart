import '../../domain/preparation_phase.dart';
import '../../domain/subject.dart';
import 'standard_quantitative_subject_base_weights.dart';

const _socialSubjectIds = <SubjectId>{
  'history',
  'geography',
  'philosophy',
  'religion',
};

const _socialMultiplierByPhase = <PreparationPhase, double>{
  PreparationPhase.early: 0.35,
  PreparationPhase.middle: 0.60,
  PreparationPhase.late: 1.00,
};

/// Phase-adjusted target weights for the standard quantitative YKS profile.
///
/// Base Weights remain unchanged. The phase only controls the gradual
/// activation of social subjects, then the complete result is normalized.
Map<SubjectId, double> standardQuantitativeTargetWeights({
  required PreparationPhase phase,
}) {
  final baseWeights = standardQuantitativeSubjectBaseWeights();
  final socialMultiplier = _socialMultiplierByPhase[phase]!;
  final adjustedWeights = <SubjectId, double>{
    for (final entry in baseWeights.entries)
      entry.key: _socialSubjectIds.contains(entry.key)
          ? entry.value * socialMultiplier
          : entry.value,
  };
  final adjustedTotal = adjustedWeights.values.fold(
    0.0,
    (total, weight) => total + weight,
  );

  return Map<SubjectId, double>.unmodifiable({
    for (final entry in adjustedWeights.entries)
      entry.key: entry.value / adjustedTotal,
  });
}
