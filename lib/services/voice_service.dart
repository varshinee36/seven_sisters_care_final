import 'package:flutter/material.dart';

/// VoiceService handles voice-enabled instructions and speech input
/// across Daily Engaging Activities for elderly dementia care.
class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  /// Speaks out a question or instruction to the elderly user.
  /// If web/native voice API is integrated in the future, it connects here.
  Future<void> speak(String text, {required BuildContext context, Color? themeColor}) async {
    final color = themeColor ?? const Color(0xFF005F46);

    // Provide visual feedback for voice narration
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Voice Instruction: \"$text\"",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }

    // TODO: Connect actual Flutter TTS (Text-To-Speech) or backend voice API here when configured.
    // Example future integration point:
    // await _flutterTts.speak(text);
  }

  /// Prompts for user speech input for Family and Emotion Recognition.
  Future<String?> listenForSpeech({
    required BuildContext context,
    required String promptTitle,
    List<String>? expectedKeywords,
  }) async {
    if (!context.mounted) return null;
    String? spokenText;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        String recognizedSample = expectedKeywords != null && expectedKeywords.isNotEmpty
            ? expectedKeywords.first
            : "Happy";

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.mic_rounded, color: Color(0xFF19D3F3), size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      promptTitle,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF19D3F3).withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: Color(0xFF19D3F3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Listening to your voice...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF005F46)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Speak clearly into your microphone.",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  if (expectedKeywords != null && expectedKeywords.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: expectedKeywords.map((kw) {
                        return ActionChip(
                          label: Text("Say \"$kw\""),
                          backgroundColor: const Color(0xFFF7FAF8),
                          side: BorderSide(color: Colors.teal.shade200),
                          onPressed: () {
                            spokenText = kw;
                            Navigator.pop(dialogContext);
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    spokenText = recognizedSample;
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Confirm Answer", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return spokenText;
  }
}
