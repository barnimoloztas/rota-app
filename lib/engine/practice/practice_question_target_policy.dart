import '../../domain/selected_mode.dart';

int practiceQuestionTargetForMode(
  SelectedMode mode,
) {
  switch (mode) {
    case SelectedMode.relaxed:
      return 30;

    case SelectedMode.balanced:
      return 40;

    case SelectedMode.strict:
      return 60;
  }
}