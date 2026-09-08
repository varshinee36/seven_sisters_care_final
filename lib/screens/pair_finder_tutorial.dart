import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'pair_finder_game.dart';

class PairFinderTutorial extends StatefulWidget {
  const PairFinderTutorial({super.key});

  @override
  State<PairFinderTutorial> createState() => _PairFinderTutorialState();
}

class _PairFinderTutorialState extends State<PairFinderTutorial> {
  late VideoPlayerController _controller;

  bool _isInitialized = false;
  bool _openingGame = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/videos/elderly_flashcard_tutorial_45sec.mp4',
    );

    _controller.addListener(_videoListener);

    _initializeVideo();
  }

  // =========================================================
  // INITIALIZE VIDEO
  // =========================================================

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      // Automatically start tutorial
      await _controller.play();
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  // =========================================================
  // CHECK VIDEO COMPLETION
  // =========================================================

  void _videoListener() {
    if (!_isInitialized || _openingGame) {
      return;
    }

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    if (_controller.value.isCompleted ||
        (duration.inMilliseconds > 0 &&
            position.inMilliseconds >= duration.inMilliseconds - 200 &&
            !_controller.value.isPlaying)) {
      _openGame();
    }
  }

  // =========================================================
  // OPEN PAIR FINDER GAME
  // =========================================================

  void _openGame() {
    if (_openingGame || !mounted) {
      return;
    }

    _openingGame = true;

    _controller.pause();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PairFinderGame()),
    );
  }

  // =========================================================
  // PLAY / PAUSE
  // =========================================================

  void _togglePlayPause() {
    if (!_isInitialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }

    setState(() {});
  }

  // =========================================================
  // SKIP TUTORIAL
  // =========================================================

  void _skipTutorial() {
    _openGame();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();

    super.dispose();
  }

  // =========================================================
  // FORMAT TIME
  // =========================================================

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final position = _isInitialized
        ? _controller.value.position
        : Duration.zero;

    final duration = _isInitialized
        ? _controller.value.duration
        : Duration.zero;

    return Scaffold(
      // Background color kept as fallback while the image loads
      backgroundColor: const Color(0xFFF7F1DF),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // =================================================
              // HEADER
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 10, 18, 18),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D5B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    // =========================================
                    // PAIR FINDER ICON (matches app icon design)
                    // =========================================
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC1876),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/pairfinder.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback so the header always shows the
                            // Pair Finder icon look even if the asset
                            // fails to load, instead of a generic icon.
                            return Container(
                              color: const Color(0xFFEC1876),
                              padding: const EdgeInsets.all(8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 4,
                                    top: 2,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFC107),
                                            Color(0xFF1E88E5),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFE53935),
                                            Color(0xFFFFA726),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pair Finder',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Watch before you play',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // CONTENT
              // =================================================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'How to Play',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF245C43),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Watch this short tutorial. '
                          'The game will start automatically '
                          'when the video finishes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.4,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // VIDEO
                      // =================================================
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _isInitialized
                              ? AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                )
                              : Container(
                                  height: 220,
                                  color: const Color(0xFFE8EFE6),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF2E7D5B),
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // =================================================
                      // VIDEO PROGRESS
                      // =================================================
                      if (_isInitialized)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Slider(
                                value: position.inMilliseconds
                                    .clamp(0, duration.inMilliseconds)
                                    .toDouble(),
                                max: duration.inMilliseconds.toDouble(),
                                activeColor: const Color(0xFF2E7D5B),
                                inactiveColor: const Color(0xFFD5E2D7),
                                onChanged: (value) {
                                  _controller.seekTo(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),

                              Row(
                                children: [
                                  Text(
                                    _formatTime(position),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const Spacer(),

                                  IconButton(
                                    onPressed: _togglePlayPause,
                                    icon: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_filled_rounded,
                                      size: 42,
                                    ),
                                    color: const Color(0xFF2E7D5B),
                                  ),

                                  const Spacer(),

                                  Text(
                                    _formatTime(duration),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 18),

                      // =================================================
                      // ELDERLY FRIENDLY INSTRUCTION
                      // =================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1E7)
                              .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFB7D1BD)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: Color(0xFF2E7D5B),
                              size: 38,
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                'Remember: Tap two cards '
                                'to find the matching food. '
                                'Take your time and enjoy!',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  color: Color(0xFF3F4D43),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // SKIP / START BUTTON
                      // =================================================
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: _skipTutorial,
                          icon: const Icon(Icons.play_arrow_rounded, size: 30),
                          label: const Text(
                            'Start Pair Finder',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE28B35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'The game starts automatically after the tutorial.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
