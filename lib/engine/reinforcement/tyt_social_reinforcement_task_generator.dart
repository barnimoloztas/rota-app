import '../../domain/tyt_social_reinforcement_lifecycle.dart';
import '../../domain/tyt_social_reinforcement_task.dart';
import 'tyt_social_reinforcement_policy.dart';

TytSocialReinforcementTask? generateTytSocialReinforcementTask({
  required TytSocialReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  final isDue = isTytSocialReinforcementDue(
    lifecycle: lifecycle,
    evaluatedAt: evaluatedAt,
  );

  return isDue ? const TytSocialReinforcementTask() : null;
}
