import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/candidate_merger.dart';

void main() {
  group('mergeCandidates', () {
    test('keeps a single candidate unchanged', () {
      const candidate = StudyCandidate(
        topicId: 'fonksiyonlar',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final result = mergeCandidates([candidate]);

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
      expect(result.first.primarySource, CandidateSource.progress);
      expect(
        result.first.sources,
        {
          CandidateSource.progress,
        },
      );
      expect(result.first.requiresBridge, isFalse);
      expect(result.first.bridgeTopicId, isNull);
    });

    test('merges same topic candidates from different sources', () {
      const progressCandidate = StudyCandidate(
        topicId: 'fonksiyonlar',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      const repairCandidate = StudyCandidate(
        topicId: 'fonksiyonlar',
        primarySource: CandidateSource.repair,
        sources: {
          CandidateSource.repair,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final result = mergeCandidates([
        progressCandidate,
        repairCandidate,
      ]);

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');

      expect(
        result.first.sources,
        containsAll({
          CandidateSource.progress,
          CandidateSource.repair,
        }),
      );
    });

    test('preserves bridge requirement when either candidate requires it', () {
      const progressCandidate = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: true,
        bridgeTopicId: 'fonksiyonlar',
      );

      const repairCandidate = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.repair,
        sources: {
          CandidateSource.repair,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final result = mergeCandidates([
        progressCandidate,
        repairCandidate,
      ]);

      expect(result, hasLength(1));
      expect(result.first.requiresBridge, isTrue);
      expect(result.first.bridgeTopicId, 'fonksiyonlar');
    });

    test('merges same bridge topic without conflict', () {
      const first = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: true,
        bridgeTopicId: 'fonksiyonlar',
      );

      const second = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.reinforcement,
        sources: {
          CandidateSource.reinforcement,
        },
        requiresBridge: true,
        bridgeTopicId: 'fonksiyonlar',
      );

      final result = mergeCandidates([
        first,
        second,
      ]);

      expect(result, hasLength(1));
      expect(result.first.bridgeTopicId, 'fonksiyonlar');

      expect(
        result.first.sources,
        containsAll({
          CandidateSource.progress,
          CandidateSource.reinforcement,
        }),
      );
    });

    test('throws when same topic candidates require different bridges', () {
      const first = StudyCandidate(
        topicId: 'ikinci_derece_denklemler_parabol',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: true,
        bridgeTopicId: 'carpanlara_ayirma',
      );

      const second = StudyCandidate(
        topicId: 'ikinci_derece_denklemler_parabol',
        primarySource: CandidateSource.repair,
        sources: {
          CandidateSource.repair,
        },
        requiresBridge: true,
        bridgeTopicId: 'denklem_cozme',
      );

      expect(
        () => mergeCandidates([
          first,
          second,
        ]),
        throwsStateError,
      );
    });

    test('keeps different topics as separate candidates', () {
      const functionsCandidate = StudyCandidate(
        topicId: 'fonksiyonlar',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      const limitsCandidate = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.repair,
        sources: {
          CandidateSource.repair,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final result = mergeCandidates([
        functionsCandidate,
        limitsCandidate,
      ]);

      expect(result, hasLength(2));

      expect(
        result.map((candidate) => candidate.topicId),
        containsAll({
          'fonksiyonlar',
          'limit_ve_sureklilik',
        }),
      );
    });
  });
}