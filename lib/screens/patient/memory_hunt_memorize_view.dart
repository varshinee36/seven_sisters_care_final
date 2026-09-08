import 'package:flutter/material.dart';

import 'memory_hunt_widgets.dart';

/// Screen 1 — Memorize objects.
/// Auto-advances after a hidden 30s timer (no Continue button, timer not shown).
class MemoryHuntMemorizeView extends StatelessWidget {
  final int level;
  final List<MemoryHuntItem> items;
  final VoidCallback onSpeaker;

  const MemoryHuntMemorizeView({
    super.key,
    required this.level,
    required this.items,
    required this.onSpeaker,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Responsive column count based on item count and screen size
    final int crossAxisCount;
    if (items.length <= 3) {
      crossAxisCount = 3;
    } else if (items.length <= 6) {
      crossAxisCount = screenWidth > 380 ? 3 : 2;
    } else {
      crossAxisCount = screenWidth > 500 ? 4 : 3;
    }

    return Column(
      children: [
        MemoryHuntHeader(onSpeaker: onSpeaker),
        const SizedBox(height: 16),
        MemoryHuntPill(
          text: 'Memory Hunt',
          color: const Color(0xFF7A97FF),
          onSpeaker: onSpeaker,
        ),
        const SizedBox(height: 10),
        MemoryHuntPill(
          text: 'Level $level of 5',
          color: const Color(0xFFEA247F),
          fontSize: 20,
          onSpeaker: onSpeaker,
        ),
        const SizedBox(height: 16),

        // Instruction card with nearby voice-over control
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF7A97FF).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Please remember these ${items.length} objects',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.25,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.black87, size: 28),
                onPressed: onSpeaker,
                tooltip: 'Voice over',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Object cards — responsive & scrollable grid
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: items.length <= 3 ? 0.85 : 0.90,
                ),
                itemBuilder: (context, index) {
                  return MemoryHuntObjectCard(
                    item: items[index],
                    minHeight: items.length <= 3 ? 130 : 105,
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
