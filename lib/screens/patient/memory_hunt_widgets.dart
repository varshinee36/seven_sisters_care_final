import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';

/// Shared model for memory object cards.
class MemoryHuntItem {
  final String id;
  final String label;
  final String assetPath;
  final IconData fallbackIcon;

  const MemoryHuntItem({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.fallbackIcon,
  });
}

// =============================================================================
// Reusable Memory Hunt UI widgets (match GamesMemoryScreen language)
// =============================================================================

class MemoryHuntHeader extends StatelessWidget {
  final VoidCallback? onSpeaker;

  const MemoryHuntHeader({super.key, this.onSpeaker});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/logo.jpg',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF005F46),
                child: Icon(Icons.psychology, color: Colors.white, size: 30),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            '11:30 AM',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.black87, size: 28),
          onPressed: onSpeaker,
          tooltip: context.loc.voiceOver,
        ),
      ],
    );
  }
}

class MemoryHuntPill extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final VoidCallback? onSpeaker;

  const MemoryHuntPill({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 22,
    this.onSpeaker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (onSpeaker != null)
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white, size: 26),
              onPressed: onSpeaker,
              tooltip: context.loc.voiceOver,
            ),
        ],
      ),
    );
  }
}

class MemoryHuntObjectCard extends StatelessWidget {
  final MemoryHuntItem item;
  final bool selected;
  final VoidCallback? onTap;
  final double minHeight;

  const MemoryHuntObjectCard({
    super.key,
    required this.item,
    this.selected = false,
    this.onTap,
    this.minHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7A97FF)
                  : const Color(0xFFE0E0E0),
              width: selected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.18 : 0.08),
                blurRadius: selected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      item.fallbackIcon,
                      size: 56,
                      color: const Color(0xFF7A97FF),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.loc.getItemLabel(item.id).startsWith('item_')
                    ? item.label
                    : context.loc.getItemLabel(item.id),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryHuntPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final double height;

  const MemoryHuntPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFF19D3F3),
    this.icon,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryHuntYellowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool expanded;

  const MemoryHuntYellowButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFB82E),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
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
    );

    if (expanded) {
      return SizedBox(height: 56, child: button);
    }
    return button;
  }
}

class MemoryHuntSpeakerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MemoryHuntSpeakerButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Tooltip(
        message: context.loc.voiceOver,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB82E),
            elevation: 2,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Icon(Icons.volume_up, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
