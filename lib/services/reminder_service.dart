import 'dart:async';

import 'package:flutter/material.dart';

enum ReminderType { medicine, hydration, doctorAppointment, customize, food }

enum ReminderStatus { pending, completed, alerted }

class Reminder {
  const Reminder({
    required this.id,
    required this.type,
    required this.label,
    required this.time,
    this.dosage,
    this.appointmentDate,
    this.photoPath,
    this.status = ReminderStatus.pending,
    this.snoozeCount = 0,
    this.snoozeUntil,
  });

  final String id;
  final ReminderType type;
  final String label;
  final TimeOfDay time;
  final String? dosage;
  final DateTime? appointmentDate;
  final String? photoPath;
  final ReminderStatus status;
  final int snoozeCount;
  final DateTime? snoozeUntil;

  bool get isCompleted => status == ReminderStatus.completed;
  bool get isAlerted => status == ReminderStatus.alerted;

  Reminder copyWith({
    String? id,
    ReminderType? type,
    String? label,
    TimeOfDay? time,
    String? dosage,
    DateTime? appointmentDate,
    String? photoPath,
    ReminderStatus? status,
    int? snoozeCount,
    DateTime? snoozeUntil,
    bool clearSnoozeUntil = false,
  }) {
    return Reminder(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      time: time ?? this.time,
      dosage: dosage ?? this.dosage,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      snoozeUntil: clearSnoozeUntil ? null : snoozeUntil ?? this.snoozeUntil,
    );
  }
}

class ReminderService extends ChangeNotifier {
  ReminderService._()
      : _reminders = [
          const Reminder(
            id: 'morning-medication',
            type: ReminderType.medicine,
            label: 'Morning Medication & Warm Water',
            time: TimeOfDay(hour: 8, minute: 0),
            dosage: '1 dose',
            status: ReminderStatus.completed,
          ),
          const Reminder(
            id: 'hydration-morning',
            type: ReminderType.hydration,
            label: 'Hydration',
            time: TimeOfDay(hour: 10, minute: 0),
            status: ReminderStatus.completed,
          ),
          const Reminder(
            id: 'lunch-noon',
            type: ReminderType.food,
            label: 'Lunch',
            time: TimeOfDay(hour: 13, minute: 0),
            status: ReminderStatus.pending,
          ),
          const Reminder(
            id: 'walking-afternoon',
            type: ReminderType.customize,
            label: 'Walking',
            time: TimeOfDay(hour: 16, minute: 0),
            status: ReminderStatus.pending,
          ),
          const Reminder(
            id: 'evening-medicine',
            type: ReminderType.medicine,
            label: 'Evening Medicine & Family Call',
            time: TimeOfDay(hour: 20, minute: 0),
            dosage: '1 dose',
            status: ReminderStatus.pending,
          ),
        ];

  static final ReminderService instance = ReminderService._();

  List<Reminder> _reminders;
  Timer? _monitorTimer;
  String? _activeAlertId;

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Reminder? get activeAlert {
    final id = _activeAlertId;
    if (id == null) return null;
    return _reminders.cast<Reminder?>().firstWhere(
      (reminder) => reminder?.id == id,
      orElse: () => null,
    );
  }

  void startMonitoring() {
    _monitorTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkDueReminders(),
    );
    _checkDueReminders();
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  void _checkDueReminders() {
    if (_activeAlertId != null) return;

    final now = DateTime.now();
    for (final reminder in _reminders) {
      if (reminder.status != ReminderStatus.pending ||
          !_matchesScheduledTime(reminder, now)) {
        continue;
      }
      if (reminder.snoozeUntil != null && reminder.snoozeUntil!.isAfter(now)) {
        continue;
      }

      _activeAlertId = reminder.id;
      notifyListeners();
      return;
    }
  }

  bool _matchesScheduledTime(Reminder reminder, DateTime now) {
    if (reminder.type == ReminderType.doctorAppointment) {
      final date = reminder.appointmentDate;
      if (date == null ||
          date.year != now.year ||
          date.month != now.month ||
          date.day != now.day) {
        return false;
      }
    }

    final scheduledMinutes = reminder.time.hour * 60 + reminder.time.minute;
    final currentMinutes = now.hour * 60 + now.minute;
    return currentMinutes == scheduledMinutes;
  }

  void triggerAlert(String reminderId) {
    _activeAlertId = reminderId;
    notifyListeners();
  }

  void addReminder(Reminder reminder) {
    _reminders = [..._reminders, reminder];
    notifyListeners();
  }

  void updateReminder(Reminder reminder) {
    final index = _reminders.indexWhere((item) => item.id == reminder.id);
    if (index == -1) return;

    final updated = [..._reminders];
    updated[index] = reminder;
    _reminders = updated;
    notifyListeners();
  }

  void removeReminder(String id) {
    if (_activeAlertId == id) _activeAlertId = null;
    _reminders = _reminders.where((reminder) => reminder.id != id).toList();
    notifyListeners();
  }

  void acknowledgeReminder(String id) {
    final reminder = _reminders.firstWhere(
      (item) => item.id == id,
      orElse: () => throw ArgumentError('Unknown reminder: $id'),
    );
    _activeAlertId = null;
    updateReminder(
      reminder.copyWith(
        status: ReminderStatus.completed,
        clearSnoozeUntil: true,
      ),
    );
  }

  void snoozeReminder(String id) {
    final reminder = _reminders.firstWhere(
      (item) => item.id == id,
      orElse: () => throw ArgumentError('Unknown reminder: $id'),
    );
    final nextCount = reminder.snoozeCount + 1;
    _activeAlertId = null;

    if (nextCount >= 3) {
      updateReminder(
        reminder.copyWith(
          status: ReminderStatus.alerted,
          snoozeCount: nextCount,
          clearSnoozeUntil: true,
        ),
      );
      return;
    }

    updateReminder(
      reminder.copyWith(
        snoozeCount: nextCount,
        snoozeUntil: DateTime.now().add(const Duration(minutes: 5)),
      ),
    );
  }

  void toggleStatus(String id) {
    final reminder = _reminders.firstWhere(
      (item) => item.id == id,
      orElse: () => throw ArgumentError('Unknown reminder: $id'),
    );
    setReminderCompleted(id, !reminder.isCompleted);
  }

  void deleteReminder(String id) => removeReminder(id);

  void setReminderCompleted(String id, bool isCompleted) {
    final reminder = _reminders.firstWhere(
      (item) => item.id == id,
      orElse: () => throw ArgumentError('Unknown reminder: $id'),
    );
    updateReminder(
      reminder.copyWith(
        status: isCompleted ? ReminderStatus.completed : ReminderStatus.pending,
        clearSnoozeUntil: true,
      ),
    );
  }
}
