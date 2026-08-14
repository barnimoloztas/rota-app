import '../../domain/daily_study_budget.dart';
import '../../domain/study_candidate.dart';
import '../../domain/study_route.dart';
import '../../domain/topic_exam_profile.dart';
import '../ranking/candidate_ranker.dart';
import 'budget_route_selector.dart';
import 'ranked_route_generator.dart';
import 'route_selector.dart';
import 'study_task_effort_policy.dart';

class BudgetedRankedRouteGenerationInput {
  const BudgetedRankedRouteGenerationInput({
    required this.candidates,
    required this.examProfilesByTopicId,
    required this.rankingConfig,
    required this.routeSelectionConfig,
    required this.studyBudget,
    required this.effortPolicyConfig,
  });

  final List<StudyCandidate> candidates;

  final Map<String, TopicExamProfile> examProfilesByTopicId;

  final RankingConfig rankingConfig;

  final RouteSelectionConfig routeSelectionConfig;

  final DailyStudyBudget studyBudget;

  final StudyTaskEffortPolicyConfig effortPolicyConfig;
}

StudyRoute generateBudgetedRankedRoute(
  BudgetedRankedRouteGenerationInput input,
) {
  final rankedRoute = generateRankedRoute(
    RankedRouteGenerationInput(
      candidates: input.candidates,
      examProfilesByTopicId: input.examProfilesByTopicId,
      rankingConfig: input.rankingConfig,
      routeSelectionConfig: input.routeSelectionConfig,
    ),
  );

  final effortEstimates = estimateRouteEfforts(
    route: rankedRoute,
    config: input.effortPolicyConfig,
  );

  return selectRouteWithinBudget(
    route: rankedRoute,
    budget: input.studyBudget,
    effortEstimates: effortEstimates,
    config: BudgetRouteSelectionConfig(
      maxTasks: input.routeSelectionConfig.maxTasks,
    ),
  );
}