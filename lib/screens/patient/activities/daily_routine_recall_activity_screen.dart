import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/voice_service.dart';

class RoutineItem {
  final String id;
  final String title;
  final int correctOrderIndex;
  final String imagePath;
  final IconData fallbackIcon;
  final Color themeColor;

  const RoutineItem({
    required this.id,
    required this.title,
    required this.correctOrderIndex,
    required this.imagePath,
    required this.fallbackIcon,
    required this.themeColor,
  });
}

class DailyRoutineRecallActivityScreen extends StatefulWidget {
  const DailyRoutineRecallActivityScreen({super.key});

  @override
  State<DailyRoutineRecallActivityScreen> createState() =>
      _DailyRoutineRecallActivityScreenState();
}

class _DailyRoutineRecallActivityScreenState
    extends State<DailyRoutineRecallActivityScreen> {
  List<RoutineItem> _getMasterRoutines(BuildContext context) {
    final loc = context.loc;
    return [
      RoutineItem(
        id: "rt_1",
        title: loc.routine1Title,
        correctOrderIndex: 0,
        imagePath: "assets/images/dailyroutinerecall.jpg",
        fallbackIcon: Icons.wb_sunny_rounded,
        themeColor: const Color(0xFFD6BA5F),
      ),
      RoutineItem(
        id: "rt_2",
        title: loc.routine2Title,
        correctOrderIndex: 1,
        imagePath: "assets/images/attention.jpg",
        fallbackIcon: Icons.clean_hands_rounded,
        themeColor: const Color(0xFF459B98),
      ),
      RoutineItem(
        id: "rt_3",
        title: loc.routine3Title,
        correctOrderIndex: 2,
        imagePath: "assets/images/activities.jpg",
        fallbackIcon: Icons.free_breakfast_rounded,
        themeColor: const Color(0xFFD64D6E),
      ),
      RoutineItem(
        id: "rt_4",
        title: loc.routine4Title,
        correctOrderIndex: 3,
        imagePath: "assets/images/background.jpg",
        fallbackIcon: Icons.nature_people_rounded,
        themeColor: const Color(0xFF4C9866),
      ),
    ];
  }

  List<String> _shuffledRoutineIds = [];
  final List<String> _userSequenceIds = [];
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initializeShuffledIds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speakInstruction();
      }
    });
  }

  void _initializeShuffledIds() {
    final ids = ["rt_1", "rt_2", "rt_3", "rt_4"]..shuffle();
    _shuffledRoutineIds = ids;
    _userSequenceIds.clear();
    _isSubmitted = false;
  }

  void _speakInstruction() {
    if (!mounted) return;
    VoiceService.instance.speak(
      context.loc.dailyRoutineInstruction,
      context: context,
      themeColor: const Color(0xFF728DF5),
    );
  }

  void _toggleSelectRoutine(String id) {
    if (_isSubmitted) return;

    setState(() {
      if (_userSequenceIds.contains(id)) {
        _userSequenceIds.remove(id);
      } else {
        if (_userSequenceIds.length < 4) {
          _userSequenceIds.add(id);
        }
      }
    });
  }

  void _resetSequence() {
    setState(() {
      _userSequenceIds.clear();
      _isSubmitted = false;
    });
  }

  void _checkSequence() {
    if (_userSequenceIds.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.selectFourPrompt),
          backgroundColor: const Color(0xFF728DF5),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });
  }

  int _calculateScore(List<RoutineItem> masterList) {
    int correctCount = 0;
    for (int i = 0; i < _userSequenceIds.length; i++) {
      final id = _userSequenceIds[i];
      final item = masterList.firstWhere((r) => r.id == id);
      if (item.correctOrderIndex == i) {
        correctCount++;
      }
    }
    return correctCount;
  }

  @override
  Widget build(BuildContext context) {
    final masterList = _getMasterRoutines(context);
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
                          errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFF728DF5),
                            child: Icon(Icons.event_repeat_rounded,
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
                              loc.dailyRoutineRecallTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4866A8),
                              ),
                            ),
                            Text(
                              loc.dailyRoutineRecallSubtitle,
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
                            size: 30, color: Color(0xFF4866A8)),
                        onPressed: _speakInstruction,
                        tooltip: 'Voice Instruction',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Main Content View
                  Expanded(
                    child: _isSubmitted
                        ? _buildResultView(masterList)
                        : _buildInteractiveRecallView(masterList),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Action Button
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

  Widget _buildInteractiveRecallView(List<RoutineItem> masterList) {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF728DF5).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: const Color(0xFF728DF5).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.wb_twilight_rounded,
                  color: Color(0xFF4866A8), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.dailyRoutineTapOrder,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4866A8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4866A8)),
                onPressed: _resetSequence,
                tooltip: loc.resetSelection,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Shuffled 2x2 Grid of Routine Cards
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: _shuffledRoutineIds.length,
            itemBuilder: (context, index) {
              final id = _shuffledRoutineIds[index];
              final item = masterList.firstWhere((r) => r.id == id);
              final sequenceIndex = _userSequenceIds.indexOf(id);
              final isSelected = sequenceIndex != -1;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleSelectRoutine(id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4866A8)
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
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18)),
                                child: Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: item.themeColor.withValues(alpha: 0.2),
                                    child: Icon(item.fallbackIcon,
                                        size: 45, color: item.themeColor),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Sequence Badge (#1, #2, #3, #4)
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4866A8),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "#${sequenceIndex + 1}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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

        const SizedBox(height: 12),

        // Action Button: Check Sequence Order
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _userSequenceIds.length == 4 ? _checkSequence : null,
            icon: const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 24),
            label: Text(
              _userSequenceIds.length == 4
                  ? loc.checkSequence
                  : loc.selectCountOfFour(_userSequenceIds.length),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(List<RoutineItem> masterList) {
    final loc = context.loc;
    final score = _calculateScore(masterList);
    final isPerfect = score == 4;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: const Color(0xFF4866A8).withValues(alpha: 0.3)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(
                    isPerfect
                        ? Icons.task_alt_rounded
                        : Icons.star_half_rounded,
                    size: 60,
                    color: const Color(0xFF4866A8),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loc.routineResult,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4866A8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.routineScoreDesc(score),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Order Comparison List
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.yourSequence,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...List.generate(_userSequenceIds.length, (idx) {
                    final id = _userSequenceIds[idx];
                    final userItem = masterList.firstWhere((r) => r.id == id);
                    final isCorrect = userItem.correctOrderIndex == idx;
                    final correctItem = masterList[idx];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF005F46).withValues(alpha: 0.1)
                            : const Color(0xFFD0456E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect
                              ? const Color(0xFF005F46)
                              : const Color(0xFFD0456E),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isCorrect
                                ? const Color(0xFF005F46)
                                : const Color(0xFFD0456E),
                            child: Text(
                              "${idx + 1}",
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userItem.title,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                if (!isCorrect)
                                  Text(
                                    loc.shouldBe(correctItem.title),
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFFD0456E)),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect
                                ? const Color(0xFF005F46)
                                : const Color(0xFFD0456E),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Shuffle & Retry Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _initializeShuffledIds();
              });
              _speakInstruction();
            },
            icon:
                const Icon(Icons.shuffle_rounded, color: Colors.white, size: 24),
            label: Text(
              loc.tryShuffledAgain,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
