import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/domain/topic_exam_profile.dart';
import 'package:rota_app/engine/candidate/candidate_aggregator.dart';

void main() {
  const examProfiles = {
    'fonksiyonlar': TopicExamProfile(
      topicId: 'fonksiyonlar',
      examImportance: 0.90,
    ),
    'trigonometri': TopicExamProfile(
      topicId: 'trigonometri',
      examImportance: 0.80,
    ),
  };

  group('aggregateCandidate', () {
    test('uses strongest candidate signal as aggregated strength', () {
      const candidate = StudyCandidate(
        topicId: 'fonksiyonlar',
        primarySource: CandidateSource.repair,
        sources: {
          CandidateSource.repair,
          CandidateSource.measurement,
          CandidateSource.reinforcement,
        },
        requiresBridge: false,
        bridgeTopicId: null,
        signals: [
          CandidateSignal(
            source: CandidateSource.repair,
            reason: CandidateReason.lowMastery,
            strength: 0.80,
          ),
          CandidateSignal(
            source: CandidateSource.measurement,
            reason: CandidateReason.lowConfidence,
            strength: 0.65,
          ),
          CandidateSignal(
            source: CandidateSource.reinforcement,
            reason: CandidateReason.masteryMaintenance,
            strength: 0.45,
          ),
        ],
      );

      final evaluation = aggregateCandidate(
        candidate,
        examProfilesByTopicId: examProfiles,
      );

      expect(evaluation.topicId, 'fonksiyonlar');
      expect(evaluation.signalStrength, 0.80);
      expect(evaluation.sourceCount, 3);
      expect(evaluation.hasBridge, isFalse);
      expect(evaluation.examImportance, 0.90);
      expect(evaluation.candidate, same(candidate));
    });

    test('returns zero signal strength when candidate has no signals', () {
      const candidate = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final evaluation = aggregateCandidate(
        candidate,
        examProfilesByTopicId: examProfiles,
      );

      expect(evaluation.signalStrength, 0.0);
      expect(evaluation.sourceCount, 1);
    });

    test('preserves bridge requirement', () {
      const candidate = StudyCandidate(
        topicId: 'limit_ve_sureklilik',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: true,
        bridgeTopicId: 'fonksiyonlar',
      );

      final evaluation = aggregateCandidate(
        candidate,
        examProfilesByTopicId: examProfiles,
      );

      expect(evaluation.hasBridge, isTrue);
      expect(evaluation.candidate.bridgeTopicId, 'fonksiyonlar');
    });

    test('counts distinct candidate sources', () {
      const candidate = StudyCandidate(
        topicId: 'trigonometri',
        primarySource: CandidateSource.repair,
        sources: {
          CandidateSource.repair,
          CandidateSource.measurement,
        },
        requiresBridge: false,
        bridgeTopicId: null,
        signals: [
          CandidateSignal(
            source: CandidateSource.repair,
            reason: CandidateReason.lowMastery,
            strength: 0.70,
          ),
          CandidateSignal(
            source: CandidateSource.measurement,
            reason: CandidateReason.lowConfidence,
            strength: 0.60,
          ),
        ],
      );

      final evaluation = aggregateCandidate(
        candidate,
        examProfilesByTopicId: examProfiles,
      );

      expect(evaluation.sourceCount, 2);
      expect(evaluation.examImportance, 0.80);
    });

    test('uses zero exam importance when profile is missing', () {
      const candidate = StudyCandidate(
        topicId: 'integral',
        primarySource: CandidateSource.progress,
        sources: {
          CandidateSource.progress,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );

      final evaluation = aggregateCandidate(
        candidate,
        examProfilesByTopicId: examProfiles,
      );

      expect(evaluation.examImportance, 0.0);
    });
  });

  group('aggregateCandidates', () {
    test('preserves candidate ordering deterministically', () {
      const candidates = [
        StudyCandidate(
          topicId: 'fonksiyonlar',
          primarySource: CandidateSource.progress,
          sources: {
            CandidateSource.progress,
          },
          requiresBridge: false,
          bridgeTopicId: null,
        ),
        StudyCandidate(
          topicId: 'trigonometri',
          primarySource: CandidateSource.repair,
          sources: {
            CandidateSource.repair,
          },
          requiresBridge: false,
          bridgeTopicId: null,
          signals: [
            CandidateSignal(
              source: CandidateSource.repair,
              reason: CandidateReason.lowMastery,
              strength: 0.85,
            ),
          ],
        ),
      ];

      final first = aggregateCandidates(
        candidates,
        examProfilesByTopicId: examProfiles,
      );

      final second = aggregateCandidates(
        candidates,
        examProfilesByTopicId: examProfiles,
      );

      expect(first, hasLength(2));
      expect(second, hasLength(2));

      for (var i = 0; i < first.length; i++) {
        expect(first[i].topicId, second[i].topicId);
        expect(
          first[i].signalStrength,
          second[i].signalStrength,
        );
        expect(
          first[i].sourceCount,
          second[i].sourceCount,
        );
        expect(
          first[i].examImportance,
          second[i].examImportance,
        );
      }
    });

    test('can aggregate an empty candidate list', () {
      final result = aggregateCandidates(
        const <StudyCandidate>[],
        examProfilesByTopicId: examProfiles,
      );

      expect(result, isEmpty);
    });
  });
}