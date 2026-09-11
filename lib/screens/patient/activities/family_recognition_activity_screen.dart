import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/voice_service.dart';

class FamilyMemberOption {
  final String id;
  final String name;
  final String relationship;
  final String imagePath;

  const FamilyMemberOption({
    required this.id,
    required this.name,
    required this.relationship,
    required this.imagePath,
  });
}

class FamilyRecognitionQuestion {
  final String voiceQuestionPrompt;
  final List<FamilyMemberOption> options;
  final String correctMemberId;
  final String hintText;

  const FamilyRecognitionQuestion({
    required this.voiceQuestionPrompt,
    required this.options,
    required this.correctMemberId,
    required this.hintText,
  });
}

class FamilyRecognitionActivityScreen extends StatefulWidget {
  const FamilyRecognitionActivityScreen({super.key});

  @override
  State<FamilyRecognitionActivityScreen> createState() =>
      _FamilyRecognitionActivityScreenState();
}

class _FamilyRecognitionActivityScreenState
    extends State<FamilyRecognitionActivityScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedMemberId;
  bool _isAnswered = false;
  int _score = 0;
  bool _isCompleted = false;

  List<FamilyRecognitionQuestion> _getQuestions(BuildContext context) {
    final loc = context.loc;
    return [
      FamilyRecognitionQuestion(
        voiceQuestionPrompt: loc.familyVoicePrompt1,
        hintText: "Daughter Maya (Guwahati)",
        correctMemberId: "fam_1",
        options: [
          FamilyMemberOption(
            id: "fam_1",
            name: "Maya Barua",
            relationship: loc.relationshipDaughter,
            imagePath: "assets/images/ner_family_1.jpg",
          ),
          FamilyMemberOption(
            id: "fam_2",
            name: "Rahul Barua",
            relationship: loc.relationshipSon,
            imagePath: "assets/images/ner_family_2.jpg",
          ),
          FamilyMemberOption(
            id: "fam_3",
            name: "Sumi Barua",
            relationship: loc.relationshipGrandmother,
            imagePath: "assets/images/ner_family_3.jpg",
          ),
          FamilyMemberOption(
            id: "fam_4",
            name: "Priyam Barua",
            relationship: loc.relationshipGrandson,
            imagePath: "assets/images/ner_family_4.jpg",
          ),
        ],
      ),
      FamilyRecognitionQuestion(
        voiceQuestionPrompt: loc.familyVoicePrompt2,
        hintText: "Son Rahul (Manipur)",
        correctMemberId: "fam_2",
        options: [
          FamilyMemberOption(
            id: "fam_3",
            name: "Sumi Barua",
            relationship: loc.relationshipGrandmother,
            imagePath: "assets/images/ner_family_3.jpg",
          ),
          FamilyMemberOption(
            id: "fam_2",
            name: "Rahul Barua",
            relationship: loc.relationshipSon,
            imagePath: "assets/images/ner_family_2.jpg",
          ),
          FamilyMemberOption(
            id: "fam_1",
            name: "Maya Barua",
            relationship: loc.relationshipDaughter,
            imagePath: "assets/images/ner_family_1.jpg",
          ),
          FamilyMemberOption(
            id: "fam_4",
            name: "Priyam Barua",
            relationship: loc.relationshipGrandson,
            imagePath: "assets/images/ner_family_4.jpg",
          ),
        ],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speakCurrentQuestion();
      }
    });
  }

  void _speakCurrentQuestion() {
    if (!mounted) return;
    final questions = _getQuestions(context);
    final currentQ = questions[_currentQuestionIndex];
    VoiceService.instance.speak(
      currentQ.voiceQuestionPrompt,
      context: context,
      themeColor: const Color(0xFF689E89),
    );
  }

  void _selectMember(String memberId, List<FamilyRecognitionQuestion> questions) {
    if (_isAnswered) return;
    final currentQ = questions[_currentQuestionIndex];
    final isCorrect = memberId == currentQ.correctMemberId;

    setState(() {
      _selectedMemberId = memberId;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });

    final selectedMember = currentQ.options.firstWhere((m) => m.id == memberId);

    _showFeedbackDialog(
      isCorrect: isCorrect,
      selectedName: selectedMember.name,
      relationship: selectedMember.relationship,
      currentQuestion: currentQ,
      totalQuestions: questions.length,
    );
  }

  Future<void> _handleVoiceAnswer(List<FamilyRecognitionQuestion> questions) async {
    final currentQ = questions[_currentQuestionIndex];
    final expectedNames =
        currentQ.options.map((o) => o.name.split(' ').first).toList();

    final result = await VoiceService.instance.listenForSpeech(
      context: context,
      promptTitle: context.loc.familyVoiceInputPrompt,
      expectedKeywords: expectedNames,
    );

    if (result != null && mounted) {
      final matchedOption = currentQ.options.firstWhere(
        (o) => o.name.toLowerCase().contains(result.toLowerCase()),
        orElse: () => currentQ.options.firstWhere((o) => o.id == currentQ.correctMemberId),
      );
      _selectMember(matchedOption.id, questions);
    }
  }

  void _showFeedbackDialog({
    required bool isCorrect,
    required String selectedName,
    required String relationship,
    required FamilyRecognitionQuestion currentQuestion,
    required int totalQuestions,
  }) {
    final loc = context.loc;
    final correctMember = currentQuestion.options
        .firstWhere((m) => m.id == currentQuestion.correctMemberId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: isCorrect ? const Color(0xFF005F46) : const Color(0xFFD0456E),
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCorrect ? loc.correctIdentification : loc.closeAttempt,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? const Color(0xFF005F46) : const Color(0xFFD0456E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF005F46).withValues(alpha: 0.1)
                    : const Color(0xFFD0456E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isCorrect
                    ? loc.familyCorrectFeedback(selectedName, relationship)
                    : loc.familyWrongFeedback(
                        selectedName,
                        relationship,
                        correctMember.name,
                        correctMember.relationship,
                      ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              _currentQuestionIndex < totalQuestions - 1
                  ? loc.nextQuestion
                  : loc.seeFinalScore,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
        _selectedMemberId = null;
        _isAnswered = false;
      });
      _speakCurrentQuestion();
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void _resetActivity() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedMemberId = null;
      _isAnswered = false;
      _score = 0;
      _isCompleted = false;
    });
    _speakCurrentQuestion();
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
                            backgroundColor: Color(0xFF689E89),
                            child: Icon(Icons.people_alt_rounded,
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
                              loc.familyRecognition,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005F46),
                              ),
                            ),
                            Text(
                              loc.familyRecognitionSubtitle,
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
                            size: 32, color: Color(0xFF005F46)),
                        onPressed: _speakCurrentQuestion,
                        tooltip: 'Listen to Voice Question',
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
      List<FamilyRecognitionQuestion> questions, FamilyRecognitionQuestion currentQuestion) {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Voice Question Prompt Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF689E89).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF689E89).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.record_voice_over_rounded,
                      color: Color(0xFF005F46), size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${loc.questionVoiceLabel(_currentQuestionIndex + 1, '')} (${_currentQuestionIndex + 1}/${questions.length})",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F46),
                      ),
                    ),
                  ),
                  // Mic Button for Speech Answer
                  InkWell(
                    onTap: () => _handleVoiceAnswer(questions),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF19D3F3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            loc.voiceInput,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                currentQuestion.voiceQuestionPrompt,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          loc.tapCorrectFamilyPhoto,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 10),

        // 2x2 Grid of Large Elderly-Friendly Family Photos
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.9,
            ),
            itemCount: currentQuestion.options.length,
            itemBuilder: (context, index) {
              final option = currentQuestion.options[index];
              final isSelected = _selectedMemberId == option.id;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectMember(option.id, questions),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF005F46)
                            : Colors.grey.shade300,
                        width: isSelected ? 3.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18)),
                            child: Image.asset(
                              option.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person,
                                    size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Column(
                            children: [
                              Text(
                                option.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                option.relationship,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF005F46),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
          border: Border.all(
              color: const Color(0xFF005F46).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF689E89),
              child: Icon(Icons.favorite, color: Colors.white, size: 45),
            ),
            const SizedBox(height: 16),
            Text(
              loc.familyRecognitionComplete,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005F46),
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
              loc.familySummaryDesc,
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
                backgroundColor: const Color(0xFF005F46),
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
