import '../../domain/selected_mode.dart';
import '../../domain/study_candidate.dart';
import '../../domain/study_route.dart';
import '../../domain/topic_exam_profile.dart';
import '../candidate/candidate_aggregator.dart';
import '../ranking/candidate_ranker.dart';
import 'route_builder.dart';
import 'route_selector.dart';

class RankedRouteGenerationInput {
  const RankedRouteGenerationInput({
    required this.candidates,
    required this.examProfilesByTopicId,
    required this.rankingConfig,
    required this.routeSelectionConfig,
    required this.selectedMode,
  });

  final List<StudyCandidate> candidates;

  final Map<String, TopicExamProfile> examProfilesByTopicId;

  final RankingConfig rankingConfig;

  final RouteSelectionConfig routeSelectionConfig;

  final SelectedMode selectedMode;
}

StudyRoute generateRankedRoute(
  RankedRouteGenerationInput input,
) {
  final evaluations = aggregateCandidates(
    input.candidates,
    examProfilesByTopicId: input.examProfilesByTopicId,
  );

  final ranked = rankCandidates(
    evaluations: evaluations,
    config: input.rankingConfig,
  );

  final orderedCandidates = ranked
      .map(
        (rankedCandidate) => rankedCandidate.evaluation.candidate,
      )
      .toList(growable: false);

  final route = buildRoute(
    candidates: orderedCandidates,
    selectedMode: input.selectedMode,
  );

  return selectRouteTasks(
    route: route,
    config: input.routeSelectionConfig,
  );
}