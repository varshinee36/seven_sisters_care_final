import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/voice_service.dart';

class ReadingPassage {
  final String title;
  final String regionTag;
  final String storyContent;
  final String imagePath;
  final List<ReadingQuestion> questions;

  const ReadingPassage({
    required this.title,
    required this.regionTag,
    required this.storyContent,
    required this.imagePath,
    required this.questions,
  });
}

class ReadingQuestion {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  const ReadingQuestion({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}

class ReadingActivityScreen extends StatefulWidget {
  const ReadingActivityScreen({super.key});

  @override
  State<ReadingActivityScreen> createState() => _ReadingActivityScreenState();
}

class _ReadingActivityScreenState extends State<ReadingActivityScreen> {
  int _selectedPassageIndex = 0;
  bool _isAnsweringQuestions = false;
  int _currentQuestionIndex = 0;
  Map<int, int> _userAnswers = {};
  bool _isSubmitted = false;

  List<ReadingPassage> _getPassages(BuildContext context) {
    final loc = context.loc;
    return [
      ReadingPassage(
        title: loc.translate('story1Title'),
        regionTag: loc.translate('story1Tag'),
        imagePath: "assets/images/r_eading.jpg",
        storyContent: loc.translate('story1Content'),
        questions: [
          ReadingQuestion(
            questionText: loc.translate('story1Q1'),
            options: [
              loc.translate('story1Q1O1'),
              loc.translate('story1Q1O2'),
              loc.translate('story1Q1O3'),
              loc.translate('story1Q1O4'),
            ],
            correctOptionIndex: 0,
          ),
          ReadingQuestion(
            questionText: loc.translate('story1Q2'),
            options: [
              loc.translate('story1Q2O1'),
              loc.translate('story1Q2O2'),
              loc.translate('story1Q2O3'),
              loc.translate('story1Q2O4'),
            ],
            correctOptionIndex: 1,
          ),
          ReadingQuestion(
            questionText: loc.translate('story1Q3'),
            options: [
              loc.translate('story1Q3O1'),
              loc.translate('story1Q3O2'),
              loc.translate('story1Q3O3'),
              loc.translate('story1Q3O4'),
            ],
            correctOptionIndex: 1,
          ),
        ],
      ),
      ReadingPassage(
        title: loc.translate('story2Title'),
        regionTag: loc.translate('story2Tag'),
        imagePath: "assets/images/reading.jpg",
        storyContent: loc.translate('story2Content'),
        questions: [
          ReadingQuestion(
            questionText: loc.translate('story2Q1'),
            options: [
              loc.translate('story2Q1O1'),
              loc.translate('story2Q1O2'),
              loc.translate('story2Q1O3'),
              loc.translate('story2Q1O4'),
            ],
            correctOptionIndex: 0,
          ),
          ReadingQuestion(
            questionText: loc.translate('story2Q2'),
            options: [
              loc.translate('story2Q2O1'),
              loc.translate('story2Q2O2'),
              loc.translate('story2Q2O3'),
              loc.translate('story2Q2O4'),
            ],
            correctOptionIndex: 1,
          ),
          ReadingQuestion(
            questionText: loc.translate('story2Q3'),
            options: [
              loc.translate('story2Q3O1'),
              loc.translate('story2Q3O2'),
              loc.translate('story2Q3O3'),
              loc.translate('story2Q3O4'),
            ],
            correctOptionIndex: 0,
          ),
        ],
      ),
    ];
  }

  void _startQuestions(ReadingPassage passage) {
    setState(() {
      _isAnsweringQuestions = true;
      _currentQuestionIndex = 0;
      _userAnswers = {};
      _isSubmitted = false;
    });

    VoiceService.instance.speak(
      "${context.loc.questionVoiceLabel(1, passage.questions[0].questionText)}",
      context: context,
      themeColor: const Color(0xFFD4B75B),
    );
  }

  void _selectOption(int questionIndex, int optionIndex) {
    if (_isSubmitted) return;
    setState(() {
      _userAnswers[questionIndex] = optionIndex;
    });
  }

  void _nextQuestion(ReadingPassage passage) {
    if (_currentQuestionIndex < passage.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      final qText = passage.questions[_currentQuestionIndex].questionText;
      VoiceService.instance.speak(
        context.loc.questionVoiceLabel(_currentQuestionIndex + 1, qText),
        context: context,
        themeColor: const Color(0xFFD4B75B),
      );
    } else {
      _submitAnswers();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitAnswers() {
    setState(() {
      _isSubmitted = true;
    });
  }

  int _calculateScore(ReadingPassage passage) {
    int count = 0;
    for (int i = 0; i < passage.questions.length; i++) {
      if (_userAnswers[i] == passage.questions[i].correctOptionIndex) {
        count++;
      }
    }
    return count;
  }

  void _resetPassage() {
    setState(() {
      _isAnsweringQuestions = false;
      _currentQuestionIndex = 0;
      _userAnswers = {};
      _isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final passages = _getPassages(context);
    if (_selectedPassageIndex >= passages.length) {
      _selectedPassageIndex = 0;
    }
    final currentPassage = passages[_selectedPassageIndex];
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
                  // Header
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFFD4B75B),
                            child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.readingActivityTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9E7C10),
                              ),
                            ),
                            Text(
                              loc.readingActivitySubtitle,
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
                        icon: const Icon(Icons.volume_up_rounded, size: 30, color: Color(0xFF9E7C10)),
                        onPressed: () {
                          if (!_isAnsweringQuestions) {
                            VoiceService.instance.speak(
                              loc.storyTitleLabel(currentPassage.title, currentPassage.storyContent),
                              context: context,
                              themeColor: const Color(0xFFD4B75B),
                            );
                          } else {
                            final q = currentPassage.questions[_currentQuestionIndex];
                            VoiceService.instance.speak(
                              loc.questionVoiceLabel(_currentQuestionIndex + 1, q.questionText),
                              context: context,
                              themeColor: const Color(0xFFD4B75B),
                            );
                          }
                        },
                        tooltip: 'Voice Read Aloud',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main Content View
                  Expanded(
                    child: _isSubmitted
                        ? _buildResultView(currentPassage)
                        : _isAnsweringQuestions
                            ? _buildQuestionView(currentPassage)
                            : _buildPassageView(passages, currentPassage),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isAnsweringQuestions || _isSubmitted) {
                          _resetPassage();
                        } else {
                          Navigator.pop(context);
                        }
                      },
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
                                _isAnsweringQuestions || _isSubmitted
                                    ? loc.backToStory
                                    : loc.backToActivities,
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

  Widget _buildPassageView(List<ReadingPassage> passages, ReadingPassage currentPassage) {
    final loc = context.loc;
    return Column(
      children: [
        // Story Selector Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(passages.length, (idx) {
              final isSel = idx == _selectedPassageIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: ChoiceChip(
                  label: Text(loc.storyNumber(idx + 1)),
                  selected: isSel,
                  selectedColor: const Color(0xFFD4B75B),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPassageIndex = idx;
                        _resetPassage();
                      });
                    }
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        // Story Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4B75B).withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4B75B).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Story Banner Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4B75B).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      currentPassage.regionTag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    currentPassage.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005F46),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Image Banner
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      currentPassage.imagePath,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: const Color(0xFFD4B75B).withValues(alpha: 0.2),
                        child: const Icon(Icons.menu_book_rounded, size: 50, color: Color(0xFF9E7C10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Story Paragraph
                  Text(
                    currentPassage.storyContent,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action Button: Read & Answer Questions
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _startQuestions(currentPassage),
            icon: const Icon(Icons.quiz_rounded, color: Colors.white, size: 26),
            label: Text(
              loc.answerQuestions,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionView(ReadingPassage currentPassage) {
    final loc = context.loc;
    final q = currentPassage.questions[_currentQuestionIndex];
    final selectedOption = _userAnswers[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${loc.questionVoiceLabel(_currentQuestionIndex + 1, '')} (${_currentQuestionIndex + 1}/${currentPassage.questions.length})",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9E7C10),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF9E7C10)),
              onPressed: () {
                VoiceService.instance.speak(
                  q.questionText,
                  context: context,
                  themeColor: const Color(0xFFD4B75B),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Linear Progress Bar
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / currentPassage.questions.length,
          backgroundColor: Colors.grey.shade300,
          color: const Color(0xFFD4B75B),
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),

        const SizedBox(height: 16),

        // Question Text Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4B75B).withValues(alpha: 0.3)),
          ),
          child: Text(
            q.questionText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Option Choices
        Expanded(
          child: ListView.separated(
            itemCount: q.options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final isOptionSelected = selectedOption == index;
              final optionLetter = String.fromCharCode(65 + index); // A, B, C, D

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectOption(_currentQuestionIndex, index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isOptionSelected
                          ? const Color(0xFF005F46).withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOptionSelected
                            ? const Color(0xFF005F46)
                            : Colors.grey.shade300,
                        width: isOptionSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isOptionSelected
                              ? const Color(0xFF005F46)
                              : Colors.grey.shade200,
                          child: Text(
                            optionLetter,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isOptionSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            q.options[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isOptionSelected ? FontWeight.bold : FontWeight.w500,
                              color: isOptionSelected ? const Color(0xFF005F46) : Colors.black87,
                            ),
                          ),
                        ),
                        if (isOptionSelected)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF005F46), size: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Navigation controls between questions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentQuestionIndex > 0)
              OutlinedButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back, size: 20),
                label: Text(loc.previous, style: const TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )
            else
              const SizedBox.shrink(),

            ElevatedButton.icon(
              onPressed: selectedOption != null ? () => _nextQuestion(currentPassage) : null,
              icon: Icon(
                _currentQuestionIndex == currentPassage.questions.length - 1
                    ? Icons.check_circle
                    : Icons.arrow_forward,
                color: Colors.white,
              ),
              label: Text(
                _currentQuestionIndex == currentPassage.questions.length - 1
                    ? loc.continueText
                    : loc.nextQuestion,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005F46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultView(ReadingPassage currentPassage) {
    final loc = context.loc;
    final totalQuestions = currentPassage.questions.length;
    final score = _calculateScore(currentPassage);
    final isPerfect = score == totalQuestions;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF005F46).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005F46).withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score Icon Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isPerfect
                        ? const Color(0xFF005F46).withValues(alpha: 0.15)
                        : const Color(0xFFD4B75B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isPerfect ? Icons.emoji_events_rounded : Icons.thumb_up_rounded,
                      size: 54,
                      color: isPerfect ? const Color(0xFF005F46) : const Color(0xFF9E7C10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  loc.activityCompleted,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),

                const SizedBox(height: 12),

                // Score Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Text(
                        loc.yourScore,
                        style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.readingScoreCorrect(score, totalQuestions),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Simple Positive Feedback for Elderly Users
                Text(
                  isPerfect
                      ? loc.readingPerfectFeedback
                      : loc.readingGoodFeedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Retry / Read Again Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _resetPassage,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
            label: Text(
              loc.readStoryAgain,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
