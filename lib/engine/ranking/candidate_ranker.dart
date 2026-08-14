import '../../domain/candidate_evaluation.dart';
import '../../domain/planning_mode.dart';
import '../../domain/study_candidate.dart';
import '../planning/planning_mode_policy.dart';

class RankingConfig {
  const RankingConfig({
    required this.signalStrengthWeight,
    required this.examImportanceWeight,
    required this.sourceDiversityWeight,
    required this.bridgeCostWeight,
    this.modeEmphasisBonus = 0.0,
    this.modeDeemphasisPenalty = 0.0,
    this.bridgeProgressModePenalty = 0.0,
  })  : assert(signalStrengthWeight >= 0.0),
        assert(examImportanceWeight >= 0.0),
        assert(sourceDiversityWeight >= 0.0),
        assert(bridgeCostWeight >= 0.0),
        assert(modeEmphasisBonus >= 0.0),
        assert(modeDeemphasisPenalty >= 0.0),
        assert(bridgeProgressModePenalty >= 0.0);

  /// Weight of the strongest pedagogical signal.
  final double signalStrengthWeight;

  /// Weight of normalized exam importance.
  final double examImportanceWeight;

  /// Weight given to agreement between multiple candidate sources.
  final double sourceDiversityWeight;

  /// Cost applied whenever a candidate requires bridge work.
  final double bridgeCostWeight;

  /// Bonus applied when the active planning mode emphasizes
  /// at least one source contributing to the candidate.
  ///
  /// Beta-calibrated; not hard-coded into the ranking algorithm.
  final double modeEmphasisBonus;

  /// Penalty applied when the active planning mode deemphasizes
  /// at least one source contributing to the candidate.
  ///
  /// Beta-calibrated.
  final double modeDeemphasisPenalty;

  /// Additional penalty for bridge-requiring progress candidates
  /// when the active planning mode explicitly discourages them.
  ///
  /// Pre-exam policy currently uses this semantic flag.
  final double bridgeProgressModePenalty;
}

class RankedCandidate {
  const RankedCandidate({
    required this.evaluation,
    required this.score,
  });

  final CandidateEvaluation evaluation;

  /// Deterministic ranking score.
  ///
  /// Ranking only orders already-eligible candidates.
  /// It must never override prerequisite gating.
  final double score;
}

List<RankedCandidate> rankCandidates({
  required Iterable<CandidateEvaluation> evaluations,
  required RankingConfig config,
  PlanningMode planningMode = PlanningMode.normal,
}) {
  final policy = planningModePolicyFor(planningMode);

  final ranked = evaluations
      .map(
        (evaluation) => RankedCandidate(
          evaluation: evaluation,
          score: _scoreCandidate(
            evaluation,
            config,
            policy,
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
  PlanningModePolicy policy,
) {
  final normalizedSourceDiversity =
      _normalizeSourceCount(evaluation.sourceCount);

  final bridgeCost =
      evaluation.hasBridge ? config.bridgeCostWeight : 0.0;

  final modeEmphasisBonus = _hasAnySource(
    evaluation.candidate.sources,
    policy.emphasizedSources,
  )
      ? config.modeEmphasisBonus
      : 0.0;

  final modeDeemphasisPenalty = _hasAnySource(
    evaluation.candidate.sources,
    policy.deemphasizedSources,
  )
      ? config.modeDeemphasisPenalty
      : 0.0;

  final bridgeProgressModePenalty =
      policy.deemphasizeBridgeProgress &&
              evaluation.hasBridge &&
              evaluation.candidate.sources.contains(
                CandidateSource.progress,
              )
          ? config.bridgeProgressModePenalty
          : 0.0;

  return (evaluation.signalStrength *
          config.signalStrengthWeight) +
      (evaluation.examImportance *
          config.examImportanceWeight) +
      (normalizedSourceDiversity *
          config.sourceDiversityWeight) +
      modeEmphasisBonus -
      bridgeCost -
      modeDeemphasisPenalty -
      bridgeProgressModePenalty;
}

bool _hasAnySource(
  Set<CandidateSource> candidateSources,
  Set<CandidateSource> policySources,
) {
  for (final source in candidateSources) {
    if (policySources.contains(source)) {
      return true;
    }
  }

  return false;
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