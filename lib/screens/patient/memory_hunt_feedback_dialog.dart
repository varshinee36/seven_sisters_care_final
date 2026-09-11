import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';

/// Feedback, hint, and answer dialogs for Memory Hunt.
class MemoryHuntFeedbackDialog {
  MemoryHuntFeedbackDialog._();

  /// Displays a hint dialog with voice-over.
  static Future<void> showHint(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onSpeaker,
  }) {
    return _showBase(
      context,
      title: title,
      message: message,
      illustration: Icons.lightbulb_rounded,
      accent: const Color(0xFFFFB82E),
      onSpeaker: onSpeaker,
      buttonText: context.loc.gotIt,
    );
  }

  /// Displays when the patient enters a wrong answer while hints remain.
  /// Prompts them to use a hint until the hint limit finishes.
  static Future<void> showTryAgainUseHint(
    BuildContext context, {
    required int hintsRemaining,
    required VoidCallback onUseHint,
    required VoidCallback onTryAgain,
    VoidCallback? onSpeaker,
  }) {
    const accent = Color(0xFFFFB82E);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row with Speaker Voice-over button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      color: Color(0xFFFFB82E),
                      size: 30,
                    ),
                    onPressed: onSpeaker,
                    tooltip: context.loc.voiceOver,
                  ),
                ],
              ),
              // Friendly illustration
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 52,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.loc.tryAgainExclamation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.loc.tryAgainPrompt(hintsRemaining),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.35,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onUseHint();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.loc.useHintWithRemaining(hintsRemaining),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onTryAgain();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7A97FF), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      context.loc.tryAgain,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A97FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Displays correct answers.
  static Future<void> showAnswers(
    BuildContext context, {
    required List<String> answers,
    VoidCallback? onSpeaker,
  }) {
    return _showBase(
      context,
      title: context.loc.answers,
      message: '${context.loc.correctObjectsWere}\n${answers.join('\n')}',
      illustration: Icons.checklist_rounded,
      accent: const Color(0xFF7A97FF),
      onSpeaker: onSpeaker,
      buttonText: context.loc.gotIt,
    );
  }

  /// Displays success feedback when all objects are correctly identified.
  static Future<void> showSuccess(
    BuildContext context, {
    required VoidCallback onContinue,
    VoidCallback? onSpeaker,
    String? message,
  }) {
    return _showBase(
      context,
      title: context.loc.wellDoneExclamation,
      message: message ?? context.loc.youRememberedCorrectly,
      illustration: Icons.emoji_emotions_rounded,
      accent: const Color(0xFF4CAF50),
      onContinue: onContinue,
      onSpeaker: onSpeaker,
      largeIllustration: true,
      buttonText: context.loc.nextLevel,
    );
  }

  /// Displays wrong answer feedback with a Back to Games action.
  static Future<void> showWrongAnswer(
    BuildContext context, {
    required VoidCallback onBackToGames,
    VoidCallback? onRetry,
    VoidCallback? onSpeaker,
    List<String>? answers,
  }) {
    const accent = Color(0xFFEA247F);
    final answersText = (answers != null && answers.isNotEmpty)
        ? '\n${context.loc.correctObjectsWere}\n${answers.join(', ')}'
        : '';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: accent, size: 30),
                    onPressed: onSpeaker,
                    tooltip: context.loc.voiceOver,
                  ),
                ],
              ),
              Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  size: 56,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Wrong Answer!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'That was not the correct set of objects.$answersText',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.35,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onBackToGames();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF19D3F3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Back to Games',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onRetry();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7A97FF), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A97FF),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  /// Celebratory dialog upon completing all 5 levels.
  static Future<void> showGameCompleted(
    BuildContext context, {
    required VoidCallback onPlayAgain,
    required VoidCallback onExit,
    VoidCallback? onSpeaker,
  }) {
    const accent = Color(0xFF4CAF50);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: accent, size: 30),
                    onPressed: onSpeaker,
                    tooltip: context.loc.voiceOver,
                  ),
                ],
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 64,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.loc.congratulationsExclamation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.loc.allLevelsCompleted,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onPlayAgain();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      context.loc.playAgain,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onExit();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7A97FF), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      context.loc.backToGames,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A97FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showBase(
    BuildContext context, {
    required String title,
    required String message,
    required IconData illustration,
    required Color accent,
    VoidCallback? onContinue,
    VoidCallback? onSpeaker,
    bool largeIllustration = false,
    String? buttonText,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_up, color: accent, size: 28),
                    onPressed: onSpeaker,
                    tooltip: context.loc.voiceOver,
                  ),
                ],
              ),
              Container(
                width: largeIllustration ? 100 : 80,
                height: largeIllustration ? 100 : 80,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  illustration,
                  size: largeIllustration ? 58 : 44,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onContinue?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  buttonText ?? context.loc.continueText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
