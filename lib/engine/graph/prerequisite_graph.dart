import '../../domain/prerequisite.dart';
import '../../domain/subject.dart';
import '../../domain/topic.dart';

typedef GraphVersion = String;

class PrerequisiteGraph {
  const PrerequisiteGraph({
    required this.subjectId,
    required this.version,
    required this.topics,
    required this.edges,
  });

  final SubjectId subjectId;
  final GraphVersion version;
  final List<Topic> topics;
  final List<PrerequisiteEdge> edges;
}