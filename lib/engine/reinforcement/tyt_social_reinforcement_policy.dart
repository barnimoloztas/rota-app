import '../../domain/tyt_social_reinforcement_lifecycle.dart';

const _tytSocialReinforcementInterval = Duration(days: 45);

DateTime tytSocialReinforcementDueAt({
  required TytSocialReinforcementLifecycle lifecycle,
}) {
  final anchor = lifecycle.lastReinforcementCompletedAt ?? lifecycle.startedAt;

  return anchor.add(_tytSocialReinforcementInterval);
}

bool isTytSocialReinforcementDue({
  required TytSocialReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  final dueAt = tytSocialReinforcementDueAt(lifecycle: lifecycle);

  return !evaluatedAt.isBefore(dueAt);
}
