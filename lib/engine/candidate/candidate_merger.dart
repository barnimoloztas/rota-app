import '../../domain/study_candidate.dart';

List<StudyCandidate> mergeCandidates(
  Iterable<StudyCandidate> candidates,
) {
  final mergedByTopic = <String, StudyCandidate>{};

  for (final candidate in candidates) {
    final existing = mergedByTopic[candidate.topicId];

    if (existing == null) {
      mergedByTopic[candidate.topicId] = StudyCandidate(
        topicId: candidate.topicId,
        primarySource: candidate.primarySource,
        sources: Set.unmodifiable(candidate.sources),
        requiresBridge: candidate.requiresBridge,
        bridgeTopicId: candidate.bridgeTopicId,
        signals: List.unmodifiable(candidate.signals),
      );

      continue;
    }

    final mergedSources = <CandidateSource>{
      ...existing.sources,
      ...candidate.sources,
    };

    final mergedSignals = <CandidateSignal>[
      ...existing.signals,
      ...candidate.signals,
    ];

    final mergedRequiresBridge =
        existing.requiresBridge || candidate.requiresBridge;

    final mergedBridgeTopicId = _mergeBridgeTopicIds(
      existing.bridgeTopicId,
      candidate.bridgeTopicId,
    );

    mergedByTopic[candidate.topicId] = StudyCandidate(
      topicId: candidate.topicId,

      // Primary source is intentionally preserved from the first candidate.
      // Ranking logic will later be responsible for selecting a dominant
      // source deterministically.
      primarySource: existing.primarySource,

      sources: Set.unmodifiable(mergedSources),
      requiresBridge: mergedRequiresBridge,
      bridgeTopicId: mergedBridgeTopicId,
      signals: List.unmodifiable(mergedSignals),
    );
  }

  return List.unmodifiable(mergedByTopic.values);
}

String? _mergeBridgeTopicIds(
  String? existingBridgeTopicId,
  String? incomingBridgeTopicId,
) {
  if (existingBridgeTopicId == null) {
    return incomingBridgeTopicId;
  }

  if (incomingBridgeTopicId == null) {
    return existingBridgeTopicId;
  }

  if (existingBridgeTopicId == incomingBridgeTopicId) {
    return existingBridgeTopicId;
  }

  throw StateError(
    'Cannot merge candidates with different bridge topics: '
    '$existingBridgeTopicId vs $incomingBridgeTopicId',
  );
}