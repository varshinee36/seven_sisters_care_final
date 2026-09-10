import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import 'memory_hunt_widgets.dart';

/// Screen 2 — Get Ready (breathing circle animation).
/// Auto-advances after ~6 seconds (no Continue button).
class MemoryHuntReadyView extends StatefulWidget {
  final VoidCallback onSpeaker;

  const MemoryHuntReadyView({
    super.key,
    required this.onSpeaker,
  });

  @override
  State<MemoryHuntReadyView> createState() => _MemoryHuntReadyViewState();
}

class _MemoryHuntReadyViewState extends State<MemoryHuntReadyView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.82, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MemoryHuntHeader(onSpeaker: widget.onSpeaker),
        const SizedBox(height: 24),
        MemoryHuntPill(
          text: context.loc.memoryHunt,
          color: const Color(0xFF7A97FF),
        ),
        const Spacer(),

        // Soft blue expanding / contracting circle
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7A97FF).withValues(alpha: 0.28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7A97FF).withValues(alpha: 0.25),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7A97FF).withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.loc.getReady,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.black87, size: 30),
              onPressed: widget.onSpeaker,
              tooltip: context.loc.voiceOver,
            ),
          ],
        ),

        const Spacer(),
        const SizedBox(height: 10),
      ],
    );
  }
}
