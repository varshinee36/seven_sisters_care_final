import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ContinuousFocusTutorial extends StatefulWidget {
  const ContinuousFocusTutorial({super.key});

  @override
  State<ContinuousFocusTutorial> createState() =>
      _ContinuousFocusTutorialState();
}

class _ContinuousFocusTutorialState extends State<ContinuousFocusTutorial> {
  late VideoPlayerController _controller;
  bool _isReady = false;

  static const Color domainColor = Color(0xFF7A4FA3); // matches Attention domain banner

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/continuous_focus_tutorial.mp4',
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: domainColor,
      body: Stack(
        children: [
          // Background image fills the whole screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Attention domain banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: domainColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: domainColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/attention.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Attention',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Continuous Focus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance the back button
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Watch how to play',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Video in a phone-style frame, on the purple domain background
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _isReady
                              ? AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: GestureDetector(
                                    onTap: _togglePlay,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        VideoPlayer(_controller),
                                        if (!_controller.value.isPlaying)
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.45),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 36,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 240,
                                  height: 420,
                                  color: Colors.black12,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Start Game button (cyan pill, same style as your Back button)
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: Material(
                      color: const Color(0xFF1BE5F2),
                      borderRadius: BorderRadius.circular(29),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(29),
                        onTap: () {
                          // TODO: replace with navigation to the real Continuous Focus game
                          Navigator.pop(context);
                        },
                        child: const Center(
                          child: Text(
                            'Start Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}