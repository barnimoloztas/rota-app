class Mastery {
  const Mastery({
    required this.score,
    required this.confidence,
  })  : assert(score >= 0.0 && score <= 100.0),
        assert(confidence >= 0.0 && confidence <= 1.0);

  /// Estimated level of mastery for the topic.
  ///
  /// Range: 0.0 - 100.0
  final double score;

  /// Confidence in the mastery estimate.
  ///
  /// Range: 0.0 - 1.0
  final double confidence;
}