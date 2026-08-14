typedef TopicId = String;

class Topic {
  const Topic({
    required this.id,
    required this.title,
  });

  final TopicId id;
  final String title;
}