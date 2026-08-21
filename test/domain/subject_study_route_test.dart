import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_study_route.dart';

void main() {
  test('SubjectStudyRoute keeps subject and its route together', () {
    const route = StudyRoute(tasks: []);

    const subjectRoute = SubjectStudyRoute(
      subjectId: 'mathematics',
      route: route,
    );

    expect(subjectRoute.subjectId, 'mathematics');
    expect(subjectRoute.route, same(route));
  });
}
