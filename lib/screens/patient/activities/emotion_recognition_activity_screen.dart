import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/voice_service.dart';

class EmotionQuestion {
  final String id;
  final String imagePath;
  final String correctEmotion;
  final String emotionDescription;
  final List<String> options;

  const EmotionQuestion({
    required this.id,
    required this.imagePath,
    required this.correctEmotion,
    required this.emotionDescription,
    required this.options,
  });
}

class EmotionRecognitionActivityScreen extends StatefulWidget {
  const EmotionRecognitionActivityScreen({super.key});

  @override
  State<EmotionRecognitionActivityScreen> createState() =>
      _EmotionRecognitionActivityScreenState();
}

class _EmotionRecognitionActivityScreenState
    extends State<EmotionRecognitionActivityScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedEmotion;
  bool _isAnswered = false;
  int _score = 0;
  bool _isCompleted = false;

  List<EmotionQuestion> _getQuestions(BuildContext context) {
    final loc = context.loc;
    return [
      EmotionQuestion(
        id: "emo_1",
        imagePath: "assets/images/ner_emotion_happy.jpg",
        correctEmotion: loc.emotionHappy,
        emotionDescription: loc.emotionHappyDesc,
        options: [loc.emotionHappy, loc.emotionSad, loc.emotionSurprised, loc.emotionAngry],
      ),
      EmotionQuestion(
        id: "emo_2",
        imagePath: "assets/images/ner_emotion_sad.jpg",
        correctEmotion: loc.emotionSad,
        emotionDescription: loc.emotionSadDesc,
        options: [loc.emotionHappy, loc.emotionSad, loc.emotionSurprised, loc.emotionCalm],
      ),
      EmotionQuestion(
        id: "emo_3",
        imagePath: "assets/images/ner_family_3.jpg",
        correctEmotion: loc.emotionCalm,
        emotionDescription: loc.emotionCalmDesc,
        options: [loc.emotionAngry, loc.emotionSurprised, loc.emotionCalm, loc.emotionSad],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speakQuestionPrompt();
      }
    });
  }

  void _speakQuestionPrompt() {
    if (!mounted) return;
    VoiceService.instance.speak(
      context.loc.howPersonFeeling,
      context: context,
      themeColor: const Color(0xFF9C27B0),
    );
  }

  void _checkEmotionAnswer(
      String emotion, EmotionQuestion currentQuestion, int totalQuestions) {
    if (_isAnswered) return;

    final isCorrect =
        emotion.toLowerCase() == currentQuestion.correctEmotion.toLowerCase();

    setState(() {
      _selectedEmotion = emotion;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });

    _showFeedbackDialog(
      isCorrect: isCorrect,
      answeredEmotion: emotion,
      currentQuestion: currentQuestion,
      totalQuestions: totalQuestions,
    );
  }

  Future<void> _handleVoiceInput(
      EmotionQuestion currentQuestion, int totalQuestions) async {
    final spoken = await VoiceService.instance.listenForSpeech(
      context: context,
      promptTitle: context.loc.identifyEmotionByVoice,
      expectedKeywords: currentQuestion.options,
    );

    if (spoken != null && mounted) {
      _checkEmotionAnswer(spoken, currentQuestion, totalQuestions);
    }
  }

  void _showFeedbackDialog({
    required bool isCorrect,
    required String answeredEmotion,
    required EmotionQuestion currentQuestion,
    required int totalQuestions,
  }) {
    final loc = context.loc;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              isCorrect
                  ? Icons.sentiment_very_satisfied_rounded
                  : Icons.info_outline_rounded,
              color:
                  isCorrect ? const Color(0xFF005F46) : const Color(0xFFD0456E),
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCorrect ? loc.greatJob : loc.niceTry,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? const Color(0xFF005F46)
                      : const Color(0xFFD0456E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF005F46).withValues(alpha: 0.1)
                    : const Color(0xFFD0456E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isCorrect
                    ? loc.emotionCorrectFeedback(
                        currentQuestion.correctEmotion,
                        currentQuestion.emotionDescription,
                      )
                    : loc.emotionWrongFeedback(
                        answeredEmotion,
                        currentQuestion.correctEmotion,
                        currentQuestion.emotionDescription,
                      ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, height: 1.4, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _nextQuestion(totalQuestions);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              _currentQuestionIndex < totalQuestions - 1
                  ? loc.nextPhoto
                  : loc.viewScore,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedEmotion = null;
        _isAnswered = false;
      });
      _speakQuestionPrompt();
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void _resetActivity() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedEmotion = null;
      _isAnswered = false;
      _score = 0;
      _isCompleted = false;
    });
    _speakQuestionPrompt();
  }

  @override
  Widget build(BuildContext context) {
    final questions = _getQuestions(context);
    final currentQuestion = questions[_currentQuestionIndex];
    final double screenWidth = MediaQuery.of(context).size.width;
    final loc = context.loc;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 600 ? 500 : double.infinity,
            margin: screenWidth > 600
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 30 : 0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Top Header
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFF9C27B0),
                            child: Icon(Icons.sentiment_satisfied_alt_rounded,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.emotionRecognition,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B1FA2),
                              ),
                            ),
                            Text(
                              loc.emotionRecognitionSubtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded,
                            size: 30, color: Color(0xFF7B1FA2)),
                        onPressed: _speakQuestionPrompt,
                        tooltip: 'Voice Guidance',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main Content Area
                  Expanded(
                    child: _isCompleted
                        ? _buildSummaryView(questions.length)
                        : _buildQuestionContent(questions, currentQuestion),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Navigation Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19D3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF19D3F3),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                loc.backToActivities,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(
      List<EmotionQuestion> questions, EmotionQuestion currentQuestion) {
    final loc = context.loc;
    return Column(
      children: [
        // Question Header Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  color: Color(0xFF7B1FA2), size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.emotionPromptHeader(
                      _currentQuestionIndex + 1, questions.length),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B1FA2)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic_rounded,
                    color: Color(0xFF19D3F3), size: 26),
                onPressed: () =>
                    _handleVoiceInput(currentQuestion, questions.length),
                tooltip: loc.speakAnswer,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Large Elderly-Friendly Face Portrait
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                currentQuestion.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.purple.shade50,
                  child: const Icon(Icons.face_rounded,
                      size: 80, color: Color(0xFF7B1FA2)),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2x2 Emotion Option Buttons
        Expanded(
          flex: 3,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemCount: currentQuestion.options.length,
            itemBuilder: (context, index) {
              final emotionText = currentQuestion.options[index];
              final isSelected = _selectedEmotion == emotionText;

              return ElevatedButton(
                onPressed: () => _checkEmotionAnswer(
                    emotionText, currentQuestion, questions.length),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? const Color(0xFF7B1FA2) : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF7B1FA2)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  emotionText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF7B1FA2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(int total) {
    final loc = context.loc;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: const Color(0xFF7B1FA2).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF9C27B0),
              child: Icon(Icons.sentiment_very_satisfied_rounded,
                  color: Colors.white, size: 45),
            ),
            const SizedBox(height: 16),
            Text(
              loc.emotionRecognitionComplete,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B1FA2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              loc.familyScoreText(_score, total),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              loc.emotionSummaryDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _resetActivity,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(loc.tryAgain,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
