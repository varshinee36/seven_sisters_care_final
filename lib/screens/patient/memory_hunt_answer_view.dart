import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import 'memory_hunt_widgets.dart';

/// Screen 3 — Answer selection (multi-select).
class MemoryHuntAnswerView extends StatelessWidget {
  final int level;
  final int targetCount;
  final int hintsRemaining;
  final List<MemoryHuntItem> items;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onHint;
  final VoidCallback onSubmit;
  final VoidCallback onSpeaker;

  const MemoryHuntAnswerView({
    super.key,
    required this.level,
    required this.targetCount,
    required this.hintsRemaining,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
    required this.onHint,
    required this.onSubmit,
    required this.onSpeaker,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        MemoryHuntHeader(onSpeaker: onSpeaker),
        const SizedBox(height: 14),

        // Instruction title with nearby voice-over
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF7A97FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.loc.selectObjectsSawEarlier(targetCount, selectedIds.length),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.white, size: 26),
                onPressed: onSpeaker,
                tooltip: context.loc.voiceOver,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Responsive grid of items
        Expanded(
          child: GridView.builder(
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 500 ? 3 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return MemoryHuntObjectCard(
                item: item,
                selected: selectedIds.contains(item.id),
                onTap: () => onToggle(item.id),
                minHeight: 130,
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Hint (with counter) + Submit + Speaker
        Row(
          children: [
            Expanded(
              child: MemoryHuntYellowButton(
                label: context.loc.hintWithCount(hintsRemaining),
                icon: Icons.lightbulb_outline,
                onPressed: onHint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MemoryHuntYellowButton(
                label: context.loc.submit,
                icon: Icons.check_circle_outline,
                onPressed: onSubmit,
              ),
            ),
            const SizedBox(width: 10),
            MemoryHuntSpeakerButton(onPressed: onSpeaker),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
