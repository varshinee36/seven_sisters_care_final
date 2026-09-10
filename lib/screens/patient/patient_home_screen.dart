import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

import 'games_screen.dart';
import 'activites_screen.dart';
import 'patient_settings_screen.dart';
import 'patient_reminders_screen.dart';
import 'patient_reminder_alert_dialog.dart';
import '../../services/family_contacts_service.dart';
import '../../services/app_launcher_service.dart';
import '../../services/reminder_service.dart';
import '../../localization/app_localizations.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final Battery _battery = Battery();
  int? _batteryLevel;
  Timer? _clockTimer;
  Timer? _batteryTimer;
  String _currentTimeString = '11:30 AM';
  String? _openReminderDialogId;

  @override
  void initState() {
    super.initState();
    _currentTimeString = _formatCurrentTime();
    _initBattery();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final nowStr = _formatCurrentTime();
      if (nowStr != _currentTimeString) {
        setState(() {
          _currentTimeString = nowStr;
        });
      }
    });

    _batteryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchBattery();
    });

    ReminderService.instance.addListener(_onReminderStateChanged);
    ReminderService.instance.startMonitoring();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _batteryTimer?.cancel();
    ReminderService.instance.removeListener(_onReminderStateChanged);
    ReminderService.instance.stopMonitoring();
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

  void _onReminderStateChanged() {
    final reminder = ReminderService.instance.activeAlert;
    if (!mounted || reminder == null || _openReminderDialogId == reminder.id) {
      return;
    }

    _openReminderDialogId = reminder.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogContext) => PatientReminderAlertDialog(
          reminder: reminder,
          onAcknowledge: () {
            ReminderService.instance.acknowledgeReminder(reminder.id);
            Navigator.of(dialogContext, rootNavigator: true).pop();
          },
          onSnooze: () {
            ReminderService.instance.snoozeReminder(reminder.id);
            Navigator.of(dialogContext, rootNavigator: true).pop();
          },
        ),
      ).whenComplete(() {
        _openReminderDialogId = null;
        if (mounted) _onReminderStateChanged();
      });
    });
  }

  void _openRemindersSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PatientRemindersScreen()),
    );
  }

  void _openFamilySheet() {
    final loc = context.loc;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return ListenableBuilder(
          listenable: FamilyContactsService.instance,
          builder: (context, _) {
            final contacts = FamilyContactsService.instance.contacts;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.diversity_3_rounded,
                              color: Color(0xFF4C9866), size: 28),
                          const SizedBox(width: 10),
                          Text(
                            loc.myFamilyAndCare,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005F46),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (contacts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          loc.noFamilyContacts,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return _buildFamilyContact(
                              contact: contact, loc: loc);
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFamilyContact(
      {required FamilyContact contact, required AppLocalizations loc}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: contact.avatarColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: contact.avatarColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: contact.avatarColor,
            radius: 20,
            child: Icon(contact.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_rounded,
                color: Color(0xFF005F46), size: 28),
            tooltip: '${loc.call} ${contact.name}',
            onPressed: () async {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "${loc.calling} ${contact.displayName} (${contact.phoneNumber})..."),
                  backgroundColor: const Color(0xFF005F46),
                  duration: const Duration(seconds: 2),
                ),
              );
              await AppLauncherService.makePhoneCall(contact.phoneNumber);
            },
          ),
        ],
      ),
    );
  }

  void _openTalkToAssistantSheet() {
    final loc = context.loc;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.voiceCompanion,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.voiceListeningPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 30),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF19D3F3).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: Color(0xFF19D3F3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildVoiceChip(loc.voiceNews, loc),
                  _buildVoiceChip(loc.voiceMusic, loc),
                  _buildVoiceChip(loc.voiceMedications, loc),
                  _buildVoiceChip(loc.voiceCallFamily, loc),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(loc.done),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceChip(String text, AppLocalizations loc) {
    return ActionChip(
      label: Text(text),
      backgroundColor: const Color(0xFFF0F7F4),
      side: const BorderSide(color: Color(0xFFCFEDE2)),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${loc.processing}: \"$text\""),
            backgroundColor: const Color(0xFF005F46),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final loc = context.loc;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 600 ? 500 : double.infinity,
            margin: screenWidth > 600
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius:
                  BorderRadius.circular(screenWidth > 600 ? 30 : 0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Top Header: Logo + 11:30 AM / 70% Charge + Voice + Settings
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const CircleAvatar(
                              radius: 32,
                              backgroundColor: Color(0xFF005F46),
                              child: Icon(Icons.favorite,
                                  color: Colors.white, size: 32),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTimeString,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                    Icons.battery_charging_full_rounded,
                                    size: 18,
                                    color: Colors.black87),
                                const SizedBox(width: 4),
                                Text(
                                  _batteryLevel != null
                                      ? "$_batteryLevel% ${loc.charge}"
                                      : "70% ${loc.charge}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up,
                            size: 28, color: Colors.black87),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.voiceOver),
                              duration: const Duration(seconds: 1),
                              backgroundColor:
                                  const Color(0xFF005F46),
                            ),
                          );
                        },
                        tooltip: loc.voiceOver,
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings,
                            size: 32, color: Color(0xFF4A4A4A)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PatientSettingsScreen(),
                            ),
                          );
                        },
                        tooltip: loc.settings,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 4 Main Feature Cards
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // 1. Games Card
                        _buildHomeCard(
                          title: loc.games,
                          color: const Color(0xFF459B98),
                          icon: Icons.psychology_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GamesScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // 2. Activities Card
                        _buildHomeCard(
                          title: loc.activities,
                          color: const Color(0xFFD64D6E),
                          icon: Icons.favorite_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ActivitesScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // 3. Reminders Card
                        _buildHomeCard(
                          title: loc.reminders,
                          color: const Color(0xFFD6BA5F),
                          icon: Icons.notifications_active_rounded,
                          onTap: _openRemindersSheet,
                        ),

                        const SizedBox(height: 14),

                        // 4. Family Card
                        _buildHomeCard(
                          title: loc.family,
                          color: const Color(0xFF4C9866),
                          icon: Icons.badge_rounded,
                          onTap: _openFamilySheet,
                        ),

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),

                  // Bottom Button: Talk To Assistant
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _openTalkToAssistantSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19D3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loc.talkToAssistant,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final loc = context.loc;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          height: 100,
          padding: const EdgeInsets.symmetric(
              horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.volume_up,
                      color: Colors.white, size: 26),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${loc.voiceGuideFor} $title"),
                        duration: const Duration(seconds: 1),
                        backgroundColor: color,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
