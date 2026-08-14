import '../../domain/candidate_evaluation.dart';

class RankingConfig {
  const RankingConfig({
    required this.signalStrengthWeight,
    required this.examImportanceWeight,
    required this.sourceDiversityWeight,
    required this.bridgeCostWeight,
  })  : assert(signalStrengthWeight >= 0.0),
        assert(examImportanceWeight >= 0.0),
        assert(sourceDiversityWeight >= 0.0),
        assert(bridgeCostWeight >= 0.0);

  /// Weight of the strongest pedagogical signal.
  final double signalStrengthWeight;

  /// Weight of normalized exam importance.
  final double examImportanceWeight;

  /// Weight given to agreement between multiple candidate sources.
  final double sourceDiversityWeight;

  /// Cost applied when a candidate requires bridge work.
  ///
  /// This is subtracted from the positive ranking components.
  final double bridgeCostWeight;
}

class RankedCandidate {
  const RankedCandidate({
    required this.evaluation,
    required this.score,
  });

  final CandidateEvaluation evaluation;

  /// Deterministic ranking score.
  ///
  /// This score orders already-eligible candidates.
  /// It must never override prerequisite gating.
  final double score;
}

List<RankedCandidate> rankCandidates({
  required Iterable<CandidateEvaluation> evaluations,
  required RankingConfig config,
}) {
  final ranked = evaluations
      .map(
        (evaluation) => RankedCandidate(
          evaluation: evaluation,
          score: _scoreCandidate(
            evaluation,
            config,
          ),
        ),
      )
      .toList();

  ranked.sort(_compareRankedCandidates);

  return List.unmodifiable(ranked);
}

double _scoreCandidate(
  CandidateEvaluation evaluation,
  RankingConfig config,
) {
  final normalizedSourceDiversity =
      _normalizeSourceCount(evaluation.sourceCount);

  final bridgeCost =
      evaluation.hasBridge ? config.bridgeCostWeight : 0.0;

  return (evaluation.signalStrength *
          config.signalStrengthWeight) +
      (evaluation.examImportance *
          config.examImportanceWeight) +
      (normalizedSourceDiversity *
          config.sourceDiversityWeight) -
      bridgeCost;
}

double _normalizeSourceCount(int sourceCount) {
  if (sourceCount <= 1) {
    return 0.0;
  }

  const maximumDistinctSources = 4;

  final additionalSources = sourceCount - 1;
  final maximumAdditionalSources =
      maximumDistinctSources - 1;

  final normalized =
      additionalSources / maximumAdditionalSources;

  if (normalized > 1.0) {
    return 1.0;
  }

  return normalized;
}

int _compareRankedCandidates(
  RankedCandidate a,
  RankedCandidate b,
) {
  // Higher score comes first.
  final scoreComparison = b.score.compareTo(a.score);

  if (scoreComparison != 0) {
    return scoreComparison;
  }

  // Deterministic tie-break:
  // lexical topic id ascending.
  return a.evaluation.topicId.compareTo(
    b.evaluation.topicId,
  );
}