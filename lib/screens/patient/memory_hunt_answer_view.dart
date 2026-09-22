import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import 'memory_hunt_widgets.dart';

/// Screen 3 — Answer selection (multi-select, with adaptive dynamic hints).
class MemoryHuntAnswerView extends StatelessWidget {
  final int level;
  final int targetCount;
  final int seconds;
  final List<MemoryHuntItem> items;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onSubmit;
  final VoidCallback onSpeaker;
  final String? hintText;
  final VoidCallback? onHintSpeaker;

  const MemoryHuntAnswerView({
    super.key,
    required this.level,
    required this.targetCount,
    required this.seconds,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
    required this.onSubmit,
    required this.onSpeaker,
    this.hintText,
    this.onHintSpeaker,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        MemoryHuntHeader(onSpeaker: onSpeaker),
        const SizedBox(height: 12),

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

        // Subtle adaptive dynamic hint banner (when struggle detected)
        if (hintText != null && hintText!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB82E), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFFD97706), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hintText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A4D05),
                      height: 1.2,
                    ),
                  ),
                ),
                if (onHintSpeaker != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Color(0xFFD97706), size: 20),
                    onPressed: onHintSpeaker,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Hint voice',
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

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

        const SizedBox(height: 10),

        // Timer Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF5D4037),
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 2.5,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D4037),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Timer : $seconds',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Submit + Speaker controls (Evaluation without hints)
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                  label: Text(
                    context.loc.submit,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB82E),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            MemoryHuntSpeakerButton(onPressed: onSpeaker),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
