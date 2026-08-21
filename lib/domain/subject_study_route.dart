import 'study_route.dart';
import 'subject.dart';

class SubjectStudyRoute {
  const SubjectStudyRoute({required this.subjectId, required this.route});

  final SubjectId subjectId;
  final StudyRoute route;

  List<StudyTask> get tasks => route.tasks;
}
