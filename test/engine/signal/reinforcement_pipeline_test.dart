import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/reinforcement_signal.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/reinforcement_candidate_generator.dart';
import 'package:rota_app/engine/signal/reinforcement_signal_generator.dart';

void main() {
  const config = ReinforcementSignalConfig(
    strengthByBand: {
      MasteryBand.proficient: 0.55,
      MasteryBand.consolidated: 0.35,
    },
  );

  StudentLearningSnapshot snapshot({
    required String topicId,
    required MasteryBand band,
    required double score,
    required double confidence,
  }) {
    final calculatedAt = DateTime.utc(2026, 8, 14);

    return StudentLearningSnapshot(
      graphVersion: '1.0.0',
      calculatedAt: calculatedAt,
      topicStates: {
        topicId: StudentTopicState(
          topicId: topicId,
          hasEvidence: true,
          mastery: Mastery(
            score: score,
            confidence: confidence,
          ),
          masteryBand: band,
          lastMeaningfulEvidenceAt: DateTime.utc(2026, 8, 13),
          calculatedAt: calculatedAt,
        ),
      },
    );
  }

  group('reinforcement signal to candidate pipeline', () {
    test(
      'proficient state becomes reinforcement candidate with preserved reason',
      () {
        final signals = generateReinforcementSignals(
          snapshot: snapshot(
            topicId: 'fonksiyonlar',
            band: MasteryBand.proficient,
            score: 82.0,
            confidence: 0.80,
          ),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          ReinforcementSignalReason.masteryMaintenance,
        );
        expect(signals.first.strength, 0.55);

        final candidate = generateReinforcementCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'fonksiyonlar');
        expect(
          candidate.primarySource,
          CandidateSource.reinforcement,
        );
        expect(candidate.signals, hasLength(1));
        expect(
          candidate.signals.first.reason,
          CandidateReason.masteryMaintenance,
        );
        expect(candidate.signals.first.strength, 0.55);
      },
    );

    test(
      'consolidated state becomes reinforcement candidate with configured strength',
      () {
        final signals = generateReinforcementSignals(
          snapshot: snapshot(
            topicId: 'turev',
            band: MasteryBand.consolidated,
            score: 92.0,
            confidence: 0.85,
          ),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(signals.first.strength, 0.35);

        final candidate = generateReinforcementCandidate(
          signal: signals.first,
        );

        expect(candidate.topicId, 'turev');
        expect(
          candidate.primarySource,
          CandidateSource.reinforcement,
        );
        expect(candidate.signals.first.strength, 0.35);
      },
    );

    test(
      'unconfigured mastery band produces no reinforcement candidate',
      () {
        final signals = generateReinforcementSignals(
          snapshot: snapshot(
            topicId: 'limit_ve_sureklilik',
            band: MasteryBand.developing,
            score: 58.0,
            confidence: 0.70,
          ),
          config: config,
        );

        expect(signals, isEmpty);
      },
    );

    test(
      'reinforcement pipeline does not invent needs-practice reason',
      () {
        final signals = generateReinforcementSignals(
          snapshot: snapshot(
            topicId: 'trigonometri',
            band: MasteryBand.proficient,
            score: 84.0,
            confidence: 0.80,
          ),
          config: config,
        );

        expect(signals, hasLength(1));
        expect(
          signals.first.reason,
          ReinforcementSignalReason.masteryMaintenance,
        );

        final candidate = generateReinforcementCandidate(
          signal: signals.first,
        );

        expect(
          candidate.signals.first.reason,
          CandidateReason.masteryMaintenance,
        );
      },
    );
  });
}