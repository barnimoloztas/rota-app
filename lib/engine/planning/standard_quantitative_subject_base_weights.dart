import '../../domain/subject.dart';

const _acceptedRoundedBaseWeights = <SubjectId, double>{
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

/// Normalized MVP Base Weights for the standard quantitative YKS profile.
///
/// Phase Adjustment and pedagogical urgency are applied outside this source.
Map<SubjectId, double> standardQuantitativeSubjectBaseWeights() {
  final roundedTotal = _acceptedRoundedBaseWeights.values.fold(
    0.0,
    (total, weight) => total + weight,
  );

  return Map<SubjectId, double>.unmodifiable({
    for (final entry in _acceptedRoundedBaseWeights.entries)
      entry.key: entry.value / roundedTotal,
  });
}
