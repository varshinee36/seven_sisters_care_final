import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/reminder_service.dart';

class PatientReminderAlertDialog extends StatefulWidget {
  const PatientReminderAlertDialog({
    super.key,
    required this.reminder,
    required this.onAcknowledge,
    required this.onSnooze,
  });

  final Reminder reminder;
  final VoidCallback onAcknowledge;
  final VoidCallback onSnooze;

  @override
  State<PatientReminderAlertDialog> createState() =>
      _PatientReminderAlertDialogState();
}

class _PatientReminderAlertDialogState
    extends State<PatientReminderAlertDialog> {
  Timer? _countdownTimer;
  int _secondsShown = 20;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsShown = _secondsShown > 0 ? _secondsShown - 1 : 20;
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.reminder;
    final typeLabel = _typeLabel(reminder.type);
    final details = reminder.type == ReminderType.medicine
        ? reminder.dosage ?? 'Not specified'
        : _formatTime(reminder.time);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2AE5D),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Reminders',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Read reminder aloud',
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reminder: ${reminder.label} at ${_formatTime(reminder.time)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            Text(
              typeLabel,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.medication_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _detailRow('Name', reminder.label),
            if (reminder.type == ReminderType.medicine)
              _detailRow('Dosage', details),
            if (reminder.type != ReminderType.medicine)
              _detailRow('Time', details),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.onAcknowledge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF70B989),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('OK'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.onSnooze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC5B68),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Snooze'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFF70451C)),
                const SizedBox(width: 6),
                Text(
                  'Timer : $_secondsShown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF70451C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label  ',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return 'Medicine Time';
      case ReminderType.hydration:
        return 'Hydration Time';
      case ReminderType.doctorAppointment:
        return 'Doctor Appointment';
      case ReminderType.customize:
        return 'Reminder Time';
      case ReminderType.food:
        return 'Meal Time';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
