import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import '../../services/reminder_service.dart';

/// Patient Reminders Screen matching the exact design of the user reference image:
/// - App logo on top left
/// - Dynamic real-time clock timing & battery charge level
/// - "Todays Remainders" header in bold dark green
/// - Rounded vibrant cards for Hydration, Lunch, Walking, and caregiver reminders
/// - Audio/Speaker icon for text-to-speech announcement
/// - Cyan pill "Back" button at bottom
class PatientRemindersScreen extends StatefulWidget {
  const PatientRemindersScreen({super.key});

  @override
  State<PatientRemindersScreen> createState() => _PatientRemindersScreenState();
}

class _PatientRemindersScreenState extends State<PatientRemindersScreen> {
  final Battery _battery = Battery();
  int? _batteryLevel;
  Timer? _clockTimer;
  Timer? _batteryTimer;
  late String _currentTimeString;

  @override
  void initState() {
    super.initState();
    _currentTimeString = _formatCurrentTime();
    _initBattery();

    // 1-second clock timer to keep time accurate
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final nowString = _formatCurrentTime();
      if (nowString != _currentTimeString) {
        setState(() {
          _currentTimeString = nowString;
        });
      }
    });

    // 30-second battery check timer
    _batteryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchBattery();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _batteryTimer?.cancel();
    super.dispose();
  }

  Future<void> _initBattery() async {
    await _fetchBattery();
  }

  Future<void> _fetchBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    } catch (_) {}
  }

  String _formatCurrentTime() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatReminderTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _speakReminder(Reminder reminder) {
    final statusText = reminder.isCompleted ? 'Completed' : 'Pending';
    final timeText = _formatReminderTime(reminder.time);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reminder: ${reminder.label} scheduled for $timeText ($statusText)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF005F46),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleReminderStatus(Reminder reminder) {
    final newStatus = !reminder.isCompleted;
    ReminderService.instance.setReminderCompleted(reminder.id, newStatus);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? 'Marked "${reminder.label}" as Completed!'
              : 'Marked "${reminder.label}" as Pending',
        ),
        backgroundColor:
            newStatus ? const Color(0xFF283567) : const Color(0xFFE65100),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 500 ? 440 : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ============================================================
                // TOP BAR: Logo + Live Digital Clock + Battery Charge
                // ============================================================
                Row(
                  children: [
                    // Circular App Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(
                            backgroundColor: Color(0xFF005F46),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Time & Battery
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentTimeString,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.battery_charging_full_rounded,
                                size: 16,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _batteryLevel != null
                                    ? '$_batteryLevel% Charge'
                                    : '70% Charge',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ============================================================
                // TITLE: "Todays Remainders"
                // ============================================================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Todays Remainders',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D533A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ============================================================
                // REMINDER CARDS LIST
                // ============================================================
                Expanded(
                  child: ListenableBuilder(
                    listenable: ReminderService.instance,
                    builder: (context, _) {
                      final reminders = ReminderService.instance.reminders;

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: reminders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final reminder = reminders[index];
                          return _buildReminderCard(reminder, index);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // ============================================================
                // BOTTOM PILL BUTTON: [<-  Back]
                // ============================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF19D3F3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF19D3F3),
                              size: 24,
                            ),
                          ),
                        ),
                        const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // REMINDER CARD BUILDER
  // ===========================================================================
  Widget _buildReminderCard(Reminder reminder, int index) {
    // Determine card visuals based on reminder type or matching the image
    final Color cardColor;
    final Widget leadingIcon;
    final Color statusTextColor;

    if (reminder.label.toLowerCase().contains('hydration') ||
        reminder.type == ReminderType.hydration) {
      cardColor = const Color(0xFF283567); // Deep navy blue
      leadingIcon = const Icon(
        Icons.water_drop_rounded,
        color: Color(0xFF64B5F6),
        size: 44,
      );
      statusTextColor = const Color(0xFFB0BEC5);
    } else if (reminder.label.toLowerCase().contains('lunch') ||
        reminder.type == ReminderType.food) {
      cardColor = const Color(0xFFF37A20); // Warm orange
      leadingIcon = const Icon(
        Icons.room_service_rounded,
        color: Color(0xFF793200),
        size: 44,
      );
      statusTextColor = const Color(0xFFCFD8DC);
    } else if (reminder.label.toLowerCase().contains('walk') ||
        reminder.type == ReminderType.customize) {
      cardColor = const Color(0xFFD74A76); // Magenta pink
      leadingIcon = const Icon(
        Icons.directions_walk_rounded,
        color: Color(0xFFFCE4EC),
        size: 44,
      );
      statusTextColor = const Color(0xFFCFD8DC);
    } else if (reminder.type == ReminderType.medicine) {
      cardColor = const Color(0xFF2E7D5B); // Forest green
      leadingIcon = const Icon(
        Icons.medication_rounded,
        color: Color(0xFFC8E6C9),
        size: 44,
      );
      statusTextColor = const Color(0xFFE8F5E9);
    } else {
      cardColor = const Color(0xFF3949AB); // Indigo
      leadingIcon = const Icon(
        Icons.event_note_rounded,
        color: Colors.white70,
        size: 44,
      );
      statusTextColor = const Color(0xFFCFD8DC);
    }

    final isCompleted = reminder.isCompleted;
    final statusText = isCompleted ? 'Completed' : 'Pending';

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: cardColor.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _toggleReminderStatus(reminder),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Left Icon
              SizedBox(
                width: 48,
                height: 48,
                child: Center(child: leadingIcon),
              ),
              const SizedBox(width: 14),

              // Title, Time, Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reminder.label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatReminderTime(reminder.time),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Speaker / Audio Button
              IconButton(
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                tooltip: 'Listen to reminder',
                onPressed: () => _speakReminder(reminder),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
