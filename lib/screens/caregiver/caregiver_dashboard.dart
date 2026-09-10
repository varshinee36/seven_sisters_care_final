import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'caregiver_analytics_dashboard.dart';
import '../../services/analytics_service.dart';
import '../../services/family_contacts_service.dart';
import '../../services/patient_service.dart';
import '../../services/reminder_service.dart';

/// Caregiver Dashboard matching the Seven Sisters Care design.
///
/// Features:
/// - Left Sidebar with Home, Remainder, Games, Activities, Reports, Analytics, Settings
/// - Report Generator with Weekly, Monthly, and Custom date ranges
/// - Complete cards matching the exact layout and content:
///   1. Patient Profile & Settings panel (collapsible)
///   2. Remainder Notifications
///   3. Memory Engaging Activities
///   4. Cognitive Games (4 Domains, 8 games)
///   5. Remainder Management (Medicine, Hydration, Customized, Doctor Appointment, Food)
///   6. Dynamic Report Generator
class CaregiverDashboard extends StatefulWidget {
  final String? caregiverUsername;

  const CaregiverDashboard({super.key, this.caregiverUsername});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  String _activeTab = 'Home';
  bool _settingsExpanded = true;
  bool _textReadingPreferenceYes = true;

  AdaptiveEngineAnalyticsData get _adaptiveAnalytics {
    final model = AnalyticsService.instance.analytics;
    if (!model.hasData) {
      return AdaptiveEngineAnalyticsData(
        cumulativeScore: 0.0,
        cumulativeAccuracy: 0.0,
        cumulativeCorrectAnswers: 0,
        cumulativeWrongAnswers: 0,
        cumulativeAttempts: 0,
        averageCompletionTime: '--',
        currentDifficulty: model.currentDifficulty,
        currentTimer: model.currentTimerDisplay,
        rlState: model.rlState,
        adaptiveAction: model.adaptiveAction,
        finalPerformanceScore: '0%',
        finalLevelReached: 0,
        lastTimerUsed: '--',
        lastPlayedGame: model.lastPlayedGame,
      );
    }

    return AdaptiveEngineAnalyticsData(
      cumulativeScore: model.overallPerformance / 100.0,
      cumulativeAccuracy: model.accuracy / 100.0,
      cumulativeCorrectAnswers: model.correctResponses,
      cumulativeWrongAnswers: model.wrongResponses,
      cumulativeAttempts: model.correctResponses + model.wrongResponses,
      averageCompletionTime: model.avgCompletionTimeDisplay,
      currentDifficulty: model.currentDifficulty,
      currentTimer: model.currentTimerDisplay,
      rlState: model.rlState,
      adaptiveAction: model.adaptiveAction,
      finalPerformanceScore: model.finalPerformanceScoreDisplay,
      finalLevelReached: model.finalLevelReached,
      lastTimerUsed: model.lastTimerUsedDisplay,
      lastPlayedGame: model.lastPlayedGame,
    );
  }

  @override
  void initState() {
    super.initState();
    PatientService.instance.addListener(_onPatientChanged);
    AnalyticsService.instance.addListener(_onAnalyticsChanged);
    final caregiverUsername = widget.caregiverUsername;
    if (caregiverUsername != null && caregiverUsername.isNotEmpty) {
      PatientService.instance.loadForCaregiver(caregiverUsername);
    }
    _loadAnalyticsForLinkedPatient();
  }

  @override
  void dispose() {
    PatientService.instance.removeListener(_onPatientChanged);
    AnalyticsService.instance.removeListener(_onAnalyticsChanged);
    super.dispose();
  }

  void _onPatientChanged() {
    if (mounted) {
      setState(() {});
      _loadAnalyticsForLinkedPatient();
    }
  }

  void _onAnalyticsChanged() {
    if (mounted) setState(() {});
  }

  void _loadAnalyticsForLinkedPatient() {
    final patient = PatientService.instance.patient;
    final patientId = patient?.patientId ?? patient?.name;
    if (patientId != null && patientId.isNotEmpty) {
      AnalyticsService.instance.fetchDashboardAnalytics(patientId);
    }
  }

  // Report Generator State: 'Weekly', 'Monthly', 'Custom'
  String _reportBasis = 'Weekly';
  DateTime _customStartDate = DateTime(2026, 5, 21);
  DateTime _customEndDate = DateTime(2026, 5, 27);

  String get _reportDateRangeString {
    switch (_reportBasis) {
      case 'Weekly':
        return '21 May 2026 ➔ 27 May 2026';
      case 'Monthly':
        return '01 May 2026 ➔ 31 May 2026';
      case 'Custom':
        final s =
            '${_customStartDate.day.toString().padLeft(2, '0')} ${_monthName(_customStartDate.month)} ${_customStartDate.year}';
        final e =
            '${_customEndDate.day.toString().padLeft(2, '0')} ${_monthName(_customEndDate.month)} ${_customEndDate.year}';
        return '$s ➔ $e';
      default:
        return '21 May 2026 ➔ 27 May 2026';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: _customStartDate,
        end: _customEndDate,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF005F46),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _reportBasis = 'Custom';
      });
    }
  }

  void _onSidebarTabSelected(String label) {
    if (label == 'Analytics') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CaregiverAnalyticsDashboard(),
        ),
      );
    } else if (label == 'Settings') {
      setState(() {
        _activeTab = label;
      });
      _showFamilyContactsDialog();
    } else {
      setState(() {
        _activeTab = label;
      });
    }
  }

  void _showFamilyContactsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            child: ListenableBuilder(
              listenable: FamilyContactsService.instance,
              builder: (ctx, _) {
                final contacts = FamilyContactsService.instance.contacts;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.contact_phone_rounded,
                            color: Color(0xFF005F46),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Family & Emergency Contacts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF005F46),
                                ),
                              ),
                              Text(
                                'Contacts appear on Patient Home screen for one-touch calling',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Add Contact Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Family Contact (Son, Daughter...)'),
                        onPressed: () => _showAddContactDialog(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F46),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contacts List
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: contacts.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(24),
                              alignment: Alignment.center,
                              child: const Text(
                                'No contacts uploaded yet. Click above to add a contact.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: contacts.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (cContext, index) {
                                final c = contacts[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7FAF8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE2EBE5)),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: c.avatarColor,
                                        radius: 18,
                                        child: Icon(c.icon,
                                            color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 6,
                                              children: [
                                                Text(
                                                  c.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: c.avatarColor
                                                        .withValues(alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    c.relationship,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: c.avatarColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              c.phoneNumber,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.redAccent, size: 20),
                                        tooltip: 'Delete contact',
                                        onPressed: () {
                                          FamilyContactsService.instance
                                              .deleteContact(c.id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddContactDialog(BuildContext parentContext) {
    final nameController = TextEditingController();
    final relationshipController = TextEditingController(text: 'Son');
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (formDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: Color(0xFF005F46)),
              SizedBox(width: 8),
              Text(
                'Add Family Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Name',
                    hintText: 'e.g. Rahul, Priya, Dr. Borah',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a contact name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    hintText: 'e.g. Son, Daughter, Caregiver, Doctor',
                    prefixIcon: Icon(Icons.family_restroom),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter relationship';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'e.g. +91 9876543210',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(formDialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005F46),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  FamilyContactsService.instance.addContact(
                    name: nameController.text.trim(),
                    relationship: relationshipController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                  );
                  Navigator.pop(formDialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Added ${nameController.text.trim()} (${relationshipController.text.trim()}) to Family Contacts!'),
                      backgroundColor: const Color(0xFF005F46),
                    ),
                  );
                }
              },
              child: const Text('Save Contact'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFD6EFE5),
      body: Row(
        children: [
          // 1. LEFT SIDEBAR
          _buildSidebar(),

          // 2. MAIN BODY
          Expanded(
            child: Container(
              color: const Color(0xFFE2F3EC),
              child: Column(
                children: [
                  // Top Header
                  _buildTopHeader(),

                  // Scrollable Dashboard Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isDesktop) ...[
                            // Desktop Row 1: Profile & Settings (3) + Remainder Notifications (3) + Activities (4)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: _buildPatientProfileAndSettingsCard()),
                                const SizedBox(width: 14),
                                Expanded(
                                    flex: 3,
                                    child: _buildRemainderNotificationsCard()),
                                const SizedBox(width: 14),
                                Expanded(
                                    flex: 4,
                                    child: _buildMemoryActivitiesCard()),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Desktop Row 2: Cognitive Games (6) + Remainder Management (5)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    children: [
                                      _buildCognitiveGamesCard(),
                                      const SizedBox(height: 14),
                                      _buildReportGeneratorCard(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 5,
                                  child: _buildRemainderManagementCard(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Desktop Row 3: Adaptive Engine & Cognitive Performance Analytics (3 Cards)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildAdaptiveEngineStatusCard(),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child:
                                      _buildCognitivePerformanceSummaryCard(),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildLatestGameSessionCard(),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Responsive single-column layout for narrower windows
                            _buildPatientProfileAndSettingsCard(),
                            const SizedBox(height: 14),
                            _buildRemainderNotificationsCard(),
                            const SizedBox(height: 14),
                            _buildMemoryActivitiesCard(),
                            const SizedBox(height: 14),
                            _buildCognitiveGamesCard(),
                            const SizedBox(height: 14),
                            _buildAdaptiveEngineStatusCard(),
                            const SizedBox(height: 14),
                            _buildCognitivePerformanceSummaryCard(),
                            const SizedBox(height: 14),
                            _buildLatestGameSessionCard(),
                            const SizedBox(height: 14),
                            _buildRemainderManagementCard(),
                            const SizedBox(height: 14),
                            _buildReportGeneratorCard(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SIDEBAR
  // ---------------------------------------------------------------------------
  Widget _buildSidebar() {
    return Container(
      width: 76,
      color: const Color(0xFFD6EFE5),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Hamburger Icon
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF005F46), size: 30),
            onPressed: () {},
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(Icons.home_rounded, 'Home'),
                _buildSidebarItem(Icons.notification_add_rounded, 'Remainder'),
                _buildSidebarItem(Icons.psychology_rounded, 'Games'),
                _buildSidebarItem(Icons.diversity_3_rounded, 'Activities'),
                _buildSidebarItem(Icons.assignment_rounded, 'Reports'),
                _buildSidebarItem(Icons.bar_chart_rounded, 'Analytics'),
                _buildSidebarItem(Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),

          // Landscape artwork at bottom
          Container(
            height: 90,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFBBE5D4),
                  child: const Icon(Icons.landscape_rounded,
                      color: Color(0xFF005F46), size: 34),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label) {
    final isSelected = _activeTab == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: InkWell(
        onTap: () => _onSidebarTabSelected(label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF74B49B) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF005F46),
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF005F46),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP HEADER BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Logo & Title
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF005F46), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Color(0xFF005F46), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Seven sisters care',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),
              Text(
                'Compassionate care everyday',
                style: TextStyle(fontSize: 11, color: Color(0xFF4CAF50)),
              ),
            ],
          ),
          const Spacer(),

          // Notification Bell
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded,
                color: Color(0xFF263238), size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 6),

          // Care Giver Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EFE5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF74B49B), width: 1),
            ),
            child: Row(
              children: const [
                Icon(Icons.person, color: Color(0xFF005F46), size: 18),
                SizedBox(width: 6),
                Text(
                  'Care Giver',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF005F46), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD 1: PATIENT PROFILE & SETTINGS
  // ---------------------------------------------------------------------------
  Widget _buildPatientProfileAndSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient info
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/family.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFFDD835),
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PatientService.instance.patient?.name ?? 'Patient Name',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F46),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          PatientService.instance.patient != null
                              ? 'Age: ${_calculateAge(PatientService.instance.patient!.dateOfBirth)}'
                              : 'Age: 67',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Text/Reading Preference',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _textReadingPreferenceYes = true),
                          child: Row(
                            children: [
                              Icon(
                                _textReadingPreferenceYes
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 14,
                                color: const Color(0xFF005F46),
                              ),
                              const SizedBox(width: 4),
                              const Text('Yes', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () =>
                              setState(() => _textReadingPreferenceYes = false),
                          child: Row(
                            children: [
                              Icon(
                                !_textReadingPreferenceYes
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 14,
                                color: const Color(0xFF005F46),
                              ),
                              const SizedBox(width: 4),
                              const Text('NO', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildPatientMetaPill(
                          icon: Icons.psychology_outlined,
                          label: PatientService.instance.patient?.dementiaStage ??
                              'Mild Dementia',
                          color: const Color(0xFF005F46),
                          bgColor: const Color(0xFFD6EFE5),
                        ),
                        _buildPatientMetaPill(
                          icon: Icons.schedule_rounded,
                          label: 'Last Active: Today 9:15 AM',
                          color: const Color(0xFF37474F),
                          bgColor: const Color(0xFFECEFF1),
                        ),
                        _buildPatientMetaPill(
                          icon: Icons.fiber_manual_record,
                          label: 'Status: Active',
                          color: const Color(0xFF2E7D32),
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Collapsible Settings
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0ECE6)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _settingsExpanded = !_settingsExpanded),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.settings,
                            size: 16, color: Color(0xFF005F46)),
                        const SizedBox(width: 8),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005F46),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _settingsExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: const Color(0xFF005F46),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_settingsExpanded) ...[
                  const Divider(height: 1, color: Color(0xFFE0ECE6)),
                  _buildSettingRow(
                    Icons.contact_phone_rounded,
                    'Family & Emergency Contacts',
                    onTap: _showFamilyContactsDialog,
                  ),
                  _buildSettingRow(Icons.language, 'Language'),
                  _buildSettingRow(Icons.palette_outlined, 'Traditional Themes'),
                  _buildSettingRow(Icons.volume_up_outlined, 'Traditional Sounds'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.logout_rounded,
                                size: 14, color: Colors.red),
                            SizedBox(width: 4),
                            Text('Logout',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Text(
                          'More',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF005F46),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF005F46)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientMetaPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // ---------------------------------------------------------------------------
  // CARD 2: REMAINDER NOTIFICATIONS
  // ---------------------------------------------------------------------------
  Widget _buildRemainderNotificationsCard() {
    return ListenableBuilder(
      listenable: ReminderService.instance,
      builder: (context, _) {
        final reminders = ReminderService.instance.reminders;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Pill
              Row(
                children: const [
                  Icon(Icons.notifications_active_rounded,
                      color: Color(0xFF005F46), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Remainder Notifications',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F46),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (reminders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No reminders set for today.',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                )
              else
                for (final r in reminders.take(5)) ...[
                  _buildNotificationPill(
                    r.label,
                    r.isCompleted
                        ? 'Completed'
                        : r.isAlerted
                            ? 'Alerted'
                            : 'Pending',
                    r.isCompleted,
                  ),
                  const SizedBox(height: 6),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationPill(String title, String status, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD48B1C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: isCompleted
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFD32F2F),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD 3: MEMORY ENGAGING ACTIVITIES
  // ---------------------------------------------------------------------------
  Widget _buildMemoryActivitiesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite_rounded, color: Color(0xFF2E7D32), size: 18),
              SizedBox(width: 8),
              Text(
                'Memory Engaging Activities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2x2 Grid of Activities
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildActivityItem(
                  'Family Recognition',
                  '40%',
                  0.40,
                  Icons.people_alt_rounded,
                  const Color(0xFFE91E63),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActivityItem(
                  'Daily Routine Recall',
                  '88%',
                  0.88,
                  Icons.schedule_rounded,
                  const Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildActivityItem(
                  'Listening to Playlist',
                  '90%',
                  0.90,
                  Icons.music_note_rounded,
                  const Color(0xFFFF4081),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActivityItem(
                  'Reading (If Preferred)',
                  '45%',
                  0.45,
                  Icons.menu_book_rounded,
                  const Color(0xFF7E57C2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String percentText, double value,
      IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              percentText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005F46),
              ),
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: const Color(0xFFE0ECE6),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD 4: COGNITIVE GAMES (4 DOMAINS)
  // ---------------------------------------------------------------------------
  Widget _buildCognitiveGamesCard() {
    final analytics = AnalyticsService.instance.analytics;
    final pairFinder = analytics.pairFinder;
    final memoryHunt = analytics.memoryHunt;
    final hasData = analytics.hasData;

    final domain1Score = (pairFinder.performance > 0 || memoryHunt.performance > 0)
        ? '${(((pairFinder.performance > 0 ? pairFinder.performance : 0) + (memoryHunt.performance > 0 ? memoryHunt.performance : 0)) / ((pairFinder.performance > 0 ? 1 : 0) + (memoryHunt.performance > 0 ? 1 : 0))).round()}%'
        : (hasData ? '${analytics.overallPerformance.round()}%' : '0%');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Color(0xFF005F46), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Cognitive Games',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),
              const Spacer(),
              if (AnalyticsService.instance.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF005F46),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Domain Columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDomainColumn(
                  '1. Memory Domain',
                  domain1Score,
                  [
                    _GameItemData(
                      'Pair Finder',
                      pairFinder.performance > 0
                          ? pairFinder.performanceDisplay
                          : (hasData && analytics.lastPlayedGame.toLowerCase().contains('pair')
                              ? '${analytics.overallPerformance.toInt()}%'
                              : '0%'),
                      pairFinder.level > 0 ? pairFinder.level : 1,
                      pairFinder.difficulty.isNotEmpty ? pairFinder.difficulty : 'Easy',
                      Icons.style,
                      const Color(0xFFE65100),
                    ),
                    _GameItemData(
                      'Memory Hunt',
                      memoryHunt.performance > 0
                          ? memoryHunt.performanceDisplay
                          : (hasData && analytics.lastPlayedGame.toLowerCase().contains('hunt')
                              ? '${analytics.overallPerformance.toInt()}%'
                              : '0%'),
                      memoryHunt.level > 0 ? memoryHunt.level : 1,
                      memoryHunt.difficulty.isNotEmpty ? memoryHunt.difficulty : 'Easy',
                      Icons.extension,
                      const Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDomainColumn(
                  '2. Attention & Concentration',
                  hasData ? '80%' : '0%',
                  [
                    _GameItemData(
                      'Continuous Focus',
                      hasData ? '90%' : '0%',
                      hasData ? 4 : 1,
                      hasData ? 'Hard' : 'Easy',
                      Icons.adjust,
                      const Color(0xFFFBC02D),
                    ),
                    _GameItemData(
                      'Find Difference',
                      hasData ? '70%' : '0%',
                      hasData ? 3 : 1,
                      hasData ? 'Medium' : 'Easy',
                      Icons.search,
                      const Color(0xFF1976D2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDomainColumn(
                  '3. Executive Plan',
                  hasData ? '82%' : '0%',
                  [
                    _GameItemData(
                      'Smartchoice',
                      hasData ? '88%' : '0%',
                      hasData ? 5 : 1,
                      hasData ? 'Hard' : 'Easy',
                      Icons.lightbulb,
                      const Color(0xFFE91E63),
                    ),
                    _GameItemData(
                      'Smart sort',
                      hasData ? '77%' : '0%',
                      hasData ? 4 : 1,
                      hasData ? 'Medium' : 'Easy',
                      Icons.inventory_2,
                      const Color(0xFF00897B),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDomainColumn(
                  '4. Perceptual Motor',
                  hasData ? '50%' : '0%',
                  [
                    _GameItemData(
                      'Shape Match',
                      hasData ? '50%' : '0%',
                      hasData ? 2 : 1,
                      hasData ? 'Easy' : 'Easy',
                      Icons.category,
                      const Color(0xFF3949AB),
                    ),
                    _GameItemData(
                      'Missing Piece',
                      hasData ? '49%' : '0%',
                      hasData ? 2 : 1,
                      hasData ? 'Easy' : 'Easy',
                      Icons.handyman,
                      const Color(0xFFD81B60),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDomainColumn(
      String title, String badgeScore, List<_GameItemData> games) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xFFCFE8DC),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeScore,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final game in games) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8F0EC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(game.icon, color: game.iconColor, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(
                              fontSize: 10.5, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Performance: ${game.performance}',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005F46),
                          ),
                        ),
                        Text(
                          'Level: ${game.level}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Difficulty: ${game.difficulty}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF546E7A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD 5: REMAINDER MANAGEMENT
  // ---------------------------------------------------------------------------
  Widget _buildRemainderManagementCard() {
    return ListenableBuilder(
      listenable: ReminderService.instance,
      builder: (context, _) {
        final reminders = ReminderService.instance.reminders;
        final medicineReminders = reminders
            .where((r) => r.type == ReminderType.medicine)
            .toList();
        final hydrationReminders = reminders
            .where((r) => r.type == ReminderType.hydration)
            .toList();
        final customReminders = reminders
            .where((r) => r.type == ReminderType.customize)
            .toList();
        final doctorReminders = reminders
            .where((r) => r.type == ReminderType.doctorAppointment)
            .toList();
        final foodReminders = reminders
            .where((r) => r.type == ReminderType.food)
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_month_rounded,
                      color: Color(0xFF005F46), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Remainder Management',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005F46),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: Medicine
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2EBE5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.medication_rounded,
                                  size: 16, color: Color(0xFF005F46)),
                              const SizedBox(width: 4),
                              const Expanded(
                                child: Text('Medicine',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _showReminderEditor(
                                    type: ReminderType.medicine),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF005F46),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('+ Add',
                                      style: TextStyle(
                                          fontSize: 8.5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (medicineReminders.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No medicine reminders added.',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            )
                          else
                            for (final med in medicineReminders) ...[
                              Text(med.label,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildPillTag(
                                            'Dosage',
                                            med.dosage ?? '1 DOSE',
                                            const Color(0xFFD4E6F1)),
                                        const SizedBox(height: 3),
                                        _buildPillTag(
                                            'Time',
                                            _formatTime(med.time),
                                            const Color(0xFFEAECEE)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _pickReminderPhoto(med),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      width: 45,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: med.photoPath != null
                                          ? const Icon(Icons.check_circle,
                                              color: Color(0xFF005F46), size: 20)
                                          : const Icon(Icons.medication,
                                              color: Color(0xFF005F46), size: 20),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 14, color: Colors.grey),
                                    onPressed: () =>
                                        _showReminderEditor(reminder: med),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Column 2: Hydration & Customized & Doctor & Food
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Hydration
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAF8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2EBE5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.water_drop,
                                            size: 14,
                                            color: Color(0xFF0288D1)),
                                        const SizedBox(width: 4),
                                        const Expanded(
                                          child: Text('Hydration',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              type: ReminderType.hydration),
                                          child: const Text('+Add',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Color(0xFF005F46),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (hydrationReminders.isEmpty)
                                      const Text('No hydration reminders',
                                          style: TextStyle(
                                              fontSize: 8.5, color: Colors.grey))
                                    else
                                      for (final h in hydrationReminders.take(2))
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              reminder: h),
                                          child: Text(
                                              'Time: ${_formatTime(h.time)}',
                                              style: const TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Customized
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAF8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2EBE5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.note_alt,
                                            size: 14,
                                            color: Color(0xFFE91E63)),
                                        const SizedBox(width: 4),
                                        const Expanded(
                                          child: Text('Customized',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              type: ReminderType.customize),
                                          child: const Text('+Add',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Color(0xFF005F46),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (customReminders.isEmpty)
                                      const Text('No custom reminders',
                                          style: TextStyle(
                                              fontSize: 8.5, color: Colors.grey))
                                    else
                                      for (final c in customReminders.take(2))
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              reminder: c),
                                          child: Text(
                                              '${c.label} ${_formatTime(c.time)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 8.5,
                                                  color: Color(0xFFD48B1C),
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Doctor Appointment & Food
                        Row(
                          children: [
                            // Doctor Appointment
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAF8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2EBE5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.medical_services,
                                            size: 14,
                                            color: Color(0xFF005F46)),
                                        const SizedBox(width: 4),
                                        const Expanded(
                                          child: Text('Doctor\nAppointment',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.1)),
                                        ),
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              type: ReminderType
                                                  .doctorAppointment),
                                          child: const Text('+Add',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Color(0xFF005F46),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (doctorReminders.isEmpty)
                                      const Text('16 May 2026\n9:00 AM',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFFD48B1C),
                                              fontWeight: FontWeight.bold))
                                    else
                                      for (final doc in doctorReminders.take(1))
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              reminder: doc),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  doc.appointmentDate != null
                                                      ? _formatDate(doc
                                                          .appointmentDate!)
                                                      : 'Date set',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFFD48B1C),
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  'Time: ${_formatTime(doc.time)}',
                                                  style: const TextStyle(
                                                      fontSize: 8)),
                                            ],
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Food
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAF8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2EBE5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.restaurant,
                                            size: 14,
                                            color: Color(0xFF5D6D7E)),
                                        const SizedBox(width: 4),
                                        const Expanded(
                                          child: Text('Food',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              type: ReminderType.food),
                                          child: const Text('+Add',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Color(0xFF005F46),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (foodReminders.isEmpty)
                                      const Text('Lunch 1:00 PM',
                                          style: TextStyle(
                                              fontSize: 8.5,
                                              color: Color(0xFFD48B1C)))
                                    else
                                      for (final f in foodReminders.take(2))
                                        InkWell(
                                          onTap: () => _showReminderEditor(
                                              reminder: f),
                                          child: Text(
                                              '${f.label} ${_formatTime(f.time)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 8.5,
                                                  color: Color(0xFFD48B1C))),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickReminderPhoto(Reminder reminder) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      ReminderService.instance.updateReminder(
        reminder.copyWith(photoPath: image.path),
      );
    }
  }

  Future<void> _showReminderEditor({
    Reminder? reminder,
    ReminderType? type,
  }) async {
    final reminderType = type ?? reminder?.type ?? ReminderType.customize;
    final labelController = TextEditingController(
      text: reminder?.label ?? _defaultReminderLabel(reminderType),
    );
    final dosageController = TextEditingController(
      text: reminder?.dosage ?? '',
    );
    var selectedTime = reminder?.time ?? TimeOfDay.now();
    var selectedDate = reminder?.appointmentDate ?? DateTime.now();
    String? photoPath = reminder?.photoPath;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final needsName =
              reminderType == ReminderType.medicine ||
              reminderType == ReminderType.customize ||
              reminderType == ReminderType.food;

          return AlertDialog(
            title: Text(
              '${reminder == null ? 'Add' : 'Edit'} ${_typeLabel(reminderType)}',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (needsName)
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                  if (reminderType == ReminderType.medicine)
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(labelText: 'Dosage'),
                    ),
                  if (reminderType == ReminderType.doctorAppointment)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date: ${_formatDate(selectedDate)}'),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: selectedDate,
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Time: ${_formatTime(selectedTime)}'),
                    trailing: const Icon(Icons.schedule),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setDialogState(() => selectedTime = time);
                      }
                    },
                  ),
                  if (reminderType == ReminderType.medicine)
                    OutlinedButton.icon(
                      icon: Icon(
                        photoPath == null ? Icons.upload_file : Icons.image,
                      ),
                      label: Text(
                        photoPath == null ? 'Upload photo' : 'Photo selected',
                      ),
                      onPressed: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setDialogState(() => photoPath = image.path);
                        }
                      },
                    ),
                ],
              ),
            ),
            actions: [
              if (reminder != null)
                TextButton(
                  onPressed: () {
                    ReminderService.instance.removeReminder(reminder.id);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final label = labelController.text.trim();
                  if (needsName && label.isEmpty) return;

                  final updated = Reminder(
                    id: reminder?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    type: reminderType,
                    label: label.isEmpty
                        ? _defaultReminderLabel(reminderType)
                        : label,
                    time: selectedTime,
                    dosage: reminderType == ReminderType.medicine
                        ? dosageController.text.trim()
                        : null,
                    appointmentDate:
                        reminderType == ReminderType.doctorAppointment
                            ? selectedDate
                            : null,
                    photoPath: photoPath,
                    status: reminder?.status ?? ReminderStatus.pending,
                  );

                  if (reminder == null) {
                    ReminderService.instance.addReminder(updated);
                  } else {
                    ReminderService.instance.updateReminder(updated);
                  }
                  Navigator.pop(dialogContext);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    labelController.dispose();
    dosageController.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _defaultReminderLabel(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return 'Medicine';
      case ReminderType.hydration:
        return 'Hydration';
      case ReminderType.doctorAppointment:
        return 'Doctor Appointment';
      case ReminderType.customize:
        return 'Activity';
      case ReminderType.food:
        return 'Meal';
    }
  }

  String _typeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return 'Medicine';
      case ReminderType.hydration:
        return 'Hydration';
      case ReminderType.doctorAppointment:
        return 'Doctor Appointment';
      case ReminderType.customize:
        return 'Customized Reminder';
      case ReminderType.food:
        return 'Food Reminder';
    }
  }

  Widget _buildPillTag(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD 6: REPORT GENERATOR (WEEKLY / MONTHLY / CUSTOM)
  // ---------------------------------------------------------------------------
  Widget _buildReportGeneratorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.assignment_rounded,
                  color: Color(0xFF005F46), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Report Generator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),
              const Spacer(),
              // Mode selection buttons: Weekly / Monthly / Custom
              _buildReportBasisChip('Weekly'),
              const SizedBox(width: 6),
              _buildReportBasisChip('Monthly'),
              const SizedBox(width: 6),
              _buildReportBasisChip('Custom'),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Date range display / picker trigger
              Expanded(
                child: InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF81C784)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range,
                            color: Color(0xFF005F46), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Generate Report For ($_reportBasis):',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF005F46),
                                ),
                              ),
                              Text(
                                _reportDateRangeString,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_reportBasis == 'Custom')
                          const Icon(Icons.edit_calendar,
                              color: Color(0xFF005F46), size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Action Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Generating $_reportBasis Report for $_reportDateRangeString...'),
                          backgroundColor: const Color(0xFF005F46),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Generate\nReport',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 14),
                      SizedBox(width: 4),
                      Text('Export as PDF',
                          style: TextStyle(
                              fontSize: 9.5,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Prepared placeholder labels for future inclusion (Requirement 6)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: const [
              _ReportSectionTag('Performance Summary'),
              _ReportSectionTag('Accuracy Summary'),
              _ReportSectionTag('Level Progression'),
              _ReportSectionTag('Adaptive Difficulty History'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportBasisChip(String label) {
    final isSelected = _reportBasis == label;

    return InkWell(
      onTap: () {
        if (label == 'Custom') {
          _pickDateRange();
        } else {
          setState(() {
            _reportBasis = label;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005F46) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF005F46) : const Color(0xFF81C784),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF005F46),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD: ADAPTIVE ENGINE STATUS (REINFORCEMENT LEARNING ANALYTICS)
  // ---------------------------------------------------------------------------
  Widget _buildAdaptiveEngineStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: Color(0xFF005F46), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Adaptive Engine Status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),
              ),
              if (AnalyticsService.instance.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF005F46),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Current RL State
          _buildAnalyticsMetricRow(
            label: 'Current RL State',
            value: _adaptiveAnalytics.rlState,
            valueColor: const Color(0xFF2E7D32),
            valueBg: const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 8),

          // Current Adaptive Action
          _buildAnalyticsMetricRow(
            label: 'Current Adaptive Action',
            value: _adaptiveAnalytics.adaptiveAction,
            valueColor: const Color(0xFF005F46),
            valueBg: const Color(0xFFD6EFE5),
          ),
          const SizedBox(height: 8),

          // Current Difficulty & Current Timer Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2EBE5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Difficulty',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF546E7A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _adaptiveAnalytics.currentDifficulty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2EBE5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Timer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF546E7A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _adaptiveAnalytics.currentTimer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Static Gradual Progression Notice (Requirement 7)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EFE5).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF74B49B).withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.verified_user_outlined,
                    size: 16, color: Color(0xFF005F46)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Adaptive progression is functioning normally.\nDifficulty adjustments are gradual and suitable for elderly users..',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF005F46),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD: COGNITIVE PERFORMANCE SUMMARY
  // ---------------------------------------------------------------------------
  Widget _buildCognitivePerformanceSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF005F46), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Cognitive Performance Summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),
              ),
              if (AnalyticsService.instance.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF005F46),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Performance',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Performance: ${(_adaptiveAnalytics.cumulativeScore * 100).toInt()}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EFE5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBE5D4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accuracy %',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF005F46),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Accuracy: ${(_adaptiveAnalytics.cumulativeAccuracy * 100).toInt()}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Row(
              children: [
                _buildStatPill(
                  label: 'Correct Responses',
                  value: 'Correct: ${_adaptiveAnalytics.cumulativeCorrectAnswers}',
                  color: const Color(0xFF2E7D32),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE0ECE6)),
                _buildStatPill(
                  label: 'Wrong Responses',
                  value: 'Wrong: ${_adaptiveAnalytics.cumulativeWrongAnswers}',
                  color: const Color(0xFFC62828),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE0ECE6)),
                _buildStatPill(
                  label: 'Average Completion Time',
                  value: 'Avg Time: ${_adaptiveAnalytics.averageCompletionTime}',
                  color: const Color(0xFF1976D2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD: LATEST GAME SESSION
  // ---------------------------------------------------------------------------
  Widget _buildLatestGameSessionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_toggle_off_rounded,
                  color: Color(0xFF005F46), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Latest Game Session',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),
              ),
              if (AnalyticsService.instance.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF005F46),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2EBE5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.style_rounded,
                              color: Color(0xFFE65100), size: 18),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Last Played Game',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF546E7A),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 3,
                      child: Text(
                        'Game: ${_adaptiveAnalytics.lastPlayedGame}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 14, color: Color(0xFFE2EBE5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      flex: 2,
                      child: Text(
                        'Final Performance',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF546E7A),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 3,
                      child: Text(
                        'Performance: ${_adaptiveAnalytics.finalPerformanceScore}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      flex: 2,
                      child: Text(
                        'Final Level Reached',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF546E7A),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 3,
                      child: Text(
                        'Level: ${_adaptiveAnalytics.finalLevelReached}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      flex: 2,
                      child: Text(
                        'Last Timer Used',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF546E7A),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 3,
                      child: Text(
                        'Timer: ${_adaptiveAnalytics.lastTimerUsed}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsMetricRow({
    required String label,
    required String value,
    required Color valueColor,
    required Color valueBg,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF546E7A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: valueBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: valueColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF546E7A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSectionTag extends StatelessWidget {
  final String label;
  const _ReportSectionTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.analytics_outlined,
              size: 10, color: Color(0xFF2E7D32)),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF005F46),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameItemData {
  final String name;
  final String performance;
  final int level;
  final String difficulty;
  final IconData icon;
  final Color iconColor;

  _GameItemData(
    this.name,
    this.performance,
    this.level,
    this.difficulty,
    this.icon,
    this.iconColor,
  );

  String get accuracy => performance;
}

class AdaptiveEngineAnalyticsData {
  final double cumulativeScore;
  final double cumulativeAccuracy;
  final int cumulativeCorrectAnswers;
  final int cumulativeWrongAnswers;
  final int cumulativeAttempts;
  final String averageCompletionTime;
  final String currentDifficulty;
  final String currentTimer;
  final String rlState;
  final String adaptiveAction;
  final String finalPerformanceScore;
  final int finalLevelReached;
  final String lastTimerUsed;
  final String lastPlayedGame;

  const AdaptiveEngineAnalyticsData({
    this.cumulativeScore = 0.82,
    this.cumulativeAccuracy = 0.88,
    this.cumulativeCorrectAnswers = 120,
    this.cumulativeWrongAnswers = 18,
    this.cumulativeAttempts = 138,
    this.averageCompletionTime = '35 sec',
    this.currentDifficulty = 'Medium',
    this.currentTimer = '51 Seconds',
    this.rlState = 'Good Performance',
    this.adaptiveAction = 'Maintain Difficulty + Maintain Timer',
    this.finalPerformanceScore = '92%',
    this.finalLevelReached = 4,
    this.lastTimerUsed = '51 sec',
    this.lastPlayedGame = 'Pair Finder',
  });

  factory AdaptiveEngineAnalyticsData.fromJson(Map<String, dynamic> json) {
    return AdaptiveEngineAnalyticsData(
      cumulativeScore: (json['cumulativeScore'] as num?)?.toDouble() ?? 0.82,
      cumulativeAccuracy:
          (json['cumulativeAccuracy'] as num?)?.toDouble() ?? 0.88,
      cumulativeCorrectAnswers:
          (json['cumulativeCorrectAnswers'] as num?)?.toInt() ?? 120,
      cumulativeWrongAnswers:
          (json['cumulativeWrongAnswers'] as num?)?.toInt() ?? 18,
      cumulativeAttempts:
          (json['cumulativeAttempts'] as num?)?.toInt() ?? 138,
      averageCompletionTime:
          (json['averageCompletionTime'] as String?) ?? '35 sec',
      currentDifficulty:
          (json['currentDifficulty'] as String?) ?? 'Medium',
      currentTimer: (json['currentTimer'] as String?) ?? '51 Seconds',
      rlState: (json['rlState'] as String?) ?? 'Good Performance',
      adaptiveAction: (json['adaptiveAction'] as String?) ??
          'Maintain Difficulty + Maintain Timer',
      finalPerformanceScore:
          (json['finalPerformanceScore'] as String?) ?? '92%',
      finalLevelReached:
          (json['finalLevelReached'] as num?)?.toInt() ?? 4,
      lastTimerUsed: (json['lastTimerUsed'] as String?) ?? '51 sec',
      lastPlayedGame: (json['lastPlayedGame'] as String?) ?? 'Pair Finder',
    );
  }
}