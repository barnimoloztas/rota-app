import '../../domain/tyt_social_reinforcement_lifecycle.dart';

TytSocialReinforcementLifecycle completeTytSocialReinforcement({
  required TytSocialReinforcementLifecycle lifecycle,
  required DateTime completedAt,
}) {
  return TytSocialReinforcementLifecycle(
    startedAt: lifecycle.startedAt,
    lastReinforcementCompletedAt: completedAt,
  );
}
