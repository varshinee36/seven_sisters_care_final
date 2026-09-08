import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'caregiver_dashboard.dart';

/// Caregiver Analytics Dashboard matching the exact UI from Image 2.
class CaregiverAnalyticsDashboard extends StatefulWidget {
  const CaregiverAnalyticsDashboard({super.key});

  @override
  State<CaregiverAnalyticsDashboard> createState() =>
      _CaregiverAnalyticsDashboardState();
}

class _CaregiverAnalyticsDashboardState
    extends State<CaregiverAnalyticsDashboard> {
  String _selectedDateRange = '21 May 2026 - 27 May 2026';
  DateTime _startDate = DateTime(2026, 5, 21);
  DateTime _endDate = DateTime(2026, 5, 27);

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
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
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedDateRange =
            '${_startDate.day} ${_monthName(_startDate.month)} ${_startDate.year} - ${_endDate.day} ${_monthName(_endDate.month)} ${_endDate.year}';
      });
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

  void _onSidebarTabSelected(String label) {
    if (label == 'Dashboard' || label == 'Home') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CaregiverDashboard()),
      );
    } else {
      // Stay on Analytics or show notification
    }
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
              color: const Color(0xFFF7FAF8),
              child: Column(
                children: [
                  // Top Header
                  _buildTopHeader(),

                  // Dashboard Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page Title & Date Range
                          _buildTitleAndFilterRow(),
                          const SizedBox(height: 12),

                          // Top Metrics Row
                          _buildTopMetricsRow(isDesktop),
                          const SizedBox(height: 14),

                          // Middle Visualizations Row (3 panels)
                          _buildMiddleVisualizationsRow(isDesktop),
                          const SizedBox(height: 14),

                          // Bottom Row (Game-wise Table + Donut/Activity + AI Insights)
                          _buildBottomRow(isDesktop),
                          const SizedBox(height: 14),

                          // Footer Note
                          _buildFooter(),
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
      width: 78,
      color: const Color(0xFFD6EFE5),
      child: Column(
        children: [
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: Color(0xFF005F46), size: 28),
            onPressed: () {},
          ),
          const SizedBox(height: 6),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(Icons.home_rounded, 'Dashboard', false),
                _buildSidebarItem(Icons.person_outline, 'Patient Profile', false),
                _buildSidebarItem(Icons.psychology_outlined, 'Cognitive Games', false),
                _buildSidebarItem(Icons.directions_run, 'Activities', false),
                _buildSidebarItem(Icons.analytics_rounded, 'Analytics', true),
                _buildSidebarItem(Icons.assignment_outlined, 'Reports', false),
                _buildSidebarItem(Icons.calendar_today_outlined, 'Reminders', false),
                _buildSidebarItem(Icons.people_outline, 'Caregivers', false),
                _buildSidebarItem(Icons.settings_outlined, 'Settings', false),
              ],
            ),
          ),

          // Landscape artwork at bottom
          Container(
            height: 85,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFBBE5D4),
                  child: const Icon(Icons.landscape,
                      color: Color(0xFF005F46), size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: InkWell(
        onTap: () => _onSidebarTabSelected(label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF74B49B) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF005F46),
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF005F46),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP HEADER
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Logo & Name
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF005F46), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Color(0xFF005F46), size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Seven Sisters Care',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),
              Text(
                'Compassionate care everyday',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF4CAF50)),
              ),
            ],
          ),
          const Spacer(),

          // Notification Bell with badge 5
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: Colors.black87, size: 24),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Care Giver Profile
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF005F46),
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Care Giver',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    'Ravi Kumar ⌄',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TITLE & DATE FILTER ROW
  // ---------------------------------------------------------------------------
  Widget _buildTitleAndFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.bar_chart_rounded, color: Color(0xFF005F46), size: 26),
            SizedBox(width: 8),
            Text(
              'Analytics Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        // Date Range Dropdown
        InkWell(
          onTap: _pickDateRange,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: Color(0xFF005F46), size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Date Range',
                        style: TextStyle(fontSize: 9, color: Colors.grey)),
                    Text(
                      _selectedDateRange,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TOP METRICS ROW (PATIENT + 5 KPI CARDS)
  // ---------------------------------------------------------------------------
  Widget _buildTopMetricsRow(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildPatientCard(),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildKPICard(
                title: 'Overall Cognitive Score',
                value: '80%',
                trend: '↑ 12% from last 7 days',
                icon: Icons.psychology,
                iconColor: const Color(0xFF9C27B0),
                iconBg: const Color(0xFFF3E5F5),
              ),
              _buildKPICard(
                title: 'Games Played',
                value: '26',
                trend: '↑ 8 from last 7 days',
                icon: Icons.sports_esports,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
              ),
              _buildKPICard(
                title: 'Activities Completed',
                value: '18',
                trend: '↑ 6 from last 7 days',
                icon: Icons.assignment_turned_in,
                iconColor: const Color(0xFF00897B),
                iconBg: const Color(0xFFE0F2F1),
              ),
              _buildKPICard(
                title: 'Reminders Completed',
                value: '24/30',
                trend: '80% Compliance',
                icon: Icons.notifications_active,
                iconColor: const Color(0xFFFFA000),
                iconBg: const Color(0xFFFFF8E1),
              ),
              _buildKPICard(
                title: 'Average Accuracy',
                value: '82%',
                trend: '↑ 9% from last 7 days',
                icon: Icons.track_changes,
                iconColor: const Color(0xFFE53935),
                iconBg: const Color(0xFFFFEBEE),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        // Patient Card (flex: 4)
        Expanded(flex: 3, child: _buildPatientCard()),
        const SizedBox(width: 10),

        // 5 KPI cards
        Expanded(
          flex: 2,
          child: _buildKPICard(
            title: 'Overall Cognitive Score',
            value: '80%',
            trend: '↑ 12% from last 7 days',
            icon: Icons.psychology,
            iconColor: const Color(0xFF9C27B0),
            iconBg: const Color(0xFFF3E5F5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildKPICard(
            title: 'Games Played',
            value: '26',
            trend: '↑ 8 from last 7 days',
            icon: Icons.sports_esports,
            iconColor: const Color(0xFF2E7D32),
            iconBg: const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildKPICard(
            title: 'Activities Completed',
            value: '18',
            trend: '↑ 6 from last 7 days',
            icon: Icons.assignment_turned_in,
            iconColor: const Color(0xFF00897B),
            iconBg: const Color(0xFFE0F2F1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildKPICard(
            title: 'Reminders Completed',
            value: '24/30',
            trend: '80% Compliance',
            icon: Icons.notifications_active,
            iconColor: const Color(0xFFFFA000),
            iconBg: const Color(0xFFFFF8E1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildKPICard(
            title: 'Average Accuracy',
            value: '82%',
            trend: '↑ 9% from last 7 days',
            icon: Icons.track_changes,
            iconColor: const Color(0xFFE53935),
            iconBg: const Color(0xFFFFEBEE),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/family.jpg',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFFDD835),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Lakshmi Devi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Age: 72  |  Female',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Text(
                  'Education: Educated',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Text(
                  'Dementia Stage: Moderate',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MIDDLE VISUALIZATIONS ROW (3 PANELS)
  // ---------------------------------------------------------------------------
  Widget _buildMiddleVisualizationsRow(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildDomainPerformanceTrendCard(),
          const SizedBox(height: 14),
          _buildReminderComplianceCard(),
          const SizedBox(height: 14),
          _buildGameAccuracyOverviewCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel 1: Domain Trend
        Expanded(flex: 7, child: _buildDomainPerformanceTrendCard()),
        const SizedBox(width: 14),

        // Panel 2: Reminder Donut
        Expanded(flex: 4, child: _buildReminderComplianceCard()),
        const SizedBox(width: 14),

        // Panel 3: Game Accuracy Bar Chart
        Expanded(flex: 5, child: _buildGameAccuracyOverviewCard()),
      ],
    );
  }

  // 1. Domain Performance Trend (Last 7 Days)
  Widget _buildDomainPerformanceTrendCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Domain Performance Trend (Last 7 Days)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Legend
          Row(
            children: [
              _buildLegendDot('Memory', const Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              _buildLegendDot('Attention', const Color(0xFF2196F3)),
              const SizedBox(width: 12),
              _buildLegendDot('Executive', const Color(0xFF9C27B0)),
              const SizedBox(width: 12),
              _buildLegendDot('Perceptual', const Color(0xFFFF9800)),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Multi-line Chart
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _DomainTrendChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }

  // 2. Reminder Compliance
  Widget _buildReminderComplianceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Reminder Compliance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Donut Chart + Legend
          Row(
            children: [
              // Donut
              SizedBox(
                width: 105,
                height: 105,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    segments: [
                      _DonutSegment(0.80, const Color(0xFF4CAF50)),
                      _DonutSegment(0.13, const Color(0xFFE53935)),
                      _DonutSegment(0.07, const Color(0xFFFFB300)),
                    ],
                    centerValue: '80%',
                    centerLabel: 'Completed',
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDonutLegendRow(
                        'Completed', '80%', const Color(0xFF4CAF50)),
                    const SizedBox(height: 8),
                    _buildDonutLegendRow(
                        'Missed', '13%', const Color(0xFFE53935)),
                    const SizedBox(height: 8),
                    _buildDonutLegendRow(
                        'Pending', '7%', const Color(0xFFFFB300)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Green Insight Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Great! Medicine and routine compliance is improving.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutLegendRow(String title, String percent, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          percent,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  // 3. Game Accuracy Overview
  Widget _buildGameAccuracyOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. Game Accuracy Overview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Bar Chart with 5 bars
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM ROW (TABLE + DONUT/ACTIVITY + AI INSIGHTS)
  // ---------------------------------------------------------------------------
  Widget _buildBottomRow(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildGameWisePerformanceCard(),
          const SizedBox(height: 14),
          _buildMiddleDonutAndActivityCard(),
          const SizedBox(height: 14),
          _buildAIInsightsCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel 4: Table (flex: 6)
        Expanded(flex: 6, child: _buildGameWisePerformanceCard()),
        const SizedBox(width: 14),

        // Panel 5: Donut & Activity Analytics (flex: 4)
        Expanded(flex: 4, child: _buildMiddleDonutAndActivityCard()),
        const SizedBox(width: 14),

        // Panel 6: AI Insights & Recommendations (flex: 5)
        Expanded(flex: 5, child: _buildAIInsightsCard()),
      ],
    );
  }

  // 4. Game Wise Performance Table
  Widget _buildGameWisePerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '4. Game Wise Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: const [
                Expanded(
                    flex: 3,
                    child: Text('Game',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
                Expanded(
                    flex: 3,
                    child: Text('Level Progress',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
                Expanded(
                    flex: 2,
                    child: Text('Accuracy',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
                Expanded(
                    flex: 2,
                    child: Text('Correct',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
                Expanded(
                    flex: 2,
                    child: Text('Wrong',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
                Expanded(
                    flex: 2,
                    child: Text('Avg. Time',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFECEFF1)),

          // 8 Table rows
          _buildTableRow('Pair Finder', Icons.style, const Color(0xFFE65100),
              '8 / 10', 0.8, '85%', '120', '20', '35 sec'),
          _buildTableRow('Memory Hunt', Icons.search, const Color(0xFF2E7D32),
              '7 / 10', 0.7, '80%', '95', '25', '42 sec'),
          _buildTableRow('Attention Game 1', Icons.adjust,
              const Color(0xFFD32F2F), '6 / 10', 0.6, '82%', '110', '18', '30 sec'),
          _buildTableRow('Attention Game 2', Icons.extension,
              const Color(0xFF7B1FA2), '5 / 10', 0.5, '74%', '90', '32', '45 sec'),
          _buildTableRow('Executive Game 1', Icons.assignment,
              const Color(0xFFF57C00), '6 / 10', 0.6, '78%', '104', '29', '50 sec'),
          _buildTableRow('Executive Game 2', Icons.view_list,
              const Color(0xFF00897B), '4 / 10', 0.4, '70%', '85', '36', '55 sec'),
          _buildTableRow('Perceptual Game 1', Icons.category,
              const Color(0xFFE91E63), '8 / 10', 0.8, '90%', '130', '14', '28 sec'),
          _buildTableRow('Perceptual Game 2', Icons.touch_app,
              const Color(0xFFFFB300), '7 / 10', 0.7, '86%', '115', '18', '33 sec'),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String game,
    IconData icon,
    Color iconColor,
    String level,
    double progress,
    String accuracy,
    String correct,
    String wrong,
    String avgTime,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Game Name + Icon
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    game,
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Level Progress Bar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE0ECE6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32)),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(level,
                    style:
                        const TextStyle(fontSize: 9.5, color: Colors.black87)),
              ],
            ),
          ),

          // Accuracy
          Expanded(
            flex: 2,
            child: Text(
              accuracy,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),

          // Correct
          Expanded(
            flex: 2,
            child: Text(
              correct,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32)),
            ),
          ),

          // Wrong
          Expanded(
            flex: 2,
            child: Text(
              wrong,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F)),
            ),
          ),

          // Avg Time
          Expanded(
            flex: 2,
            child: Text(
              avgTime,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Correct vs Wrong Responses & 6. Activity Analytics
  Widget _buildMiddleDonutAndActivityCard() {
    return Column(
      children: [
        // 5. Correct vs Wrong Responses
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '5. Correct vs Wrong Responses',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CustomPaint(
                      painter: _DonutChartPainter(
                        segments: [
                          _DonutSegment(0.81, const Color(0xFF4CAF50)),
                          _DonutSegment(0.19, const Color(0xFFE53935)),
                        ],
                        centerValue: '1280',
                        centerLabel: 'Total',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDonutLegendRow(
                            'Correct', '1040 (81%)', const Color(0xFF4CAF50)),
                        const SizedBox(height: 8),
                        _buildDonutLegendRow(
                            'Wrong', '240 (19%)', const Color(0xFFE53935)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 6. Activity Analytics
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '6. Activity Analytics',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildActivityAnalyticsRow(Icons.group, const Color(0xFFE91E63),
                  'Family Recognition', '40%', '↑ 10%'),
              _buildActivityAnalyticsRow(Icons.event, const Color(0xFF00BCD4),
                  'Daily Routine Recall', '88%', '↑ 15%'),
              _buildActivityAnalyticsRow(Icons.music_note,
                  const Color(0xFFFF4081), 'Listening to Playlist', '90 min', '↑ 20 min'),
              _buildActivityAnalyticsRow(Icons.menu_book,
                  const Color(0xFF7E57C2), 'Reading Progress', '45%', '↑ 8%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityAnalyticsRow(IconData icon, Color iconColor,
      String title, String value, String trend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Text(
            trend,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  // AI Insights & Recommendations
  Widget _buildAIInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFF005F46), size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'AI Insights & Recommendations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildInsightItem(
            Icons.trending_up,
            const Color(0xFF2E7D32),
            const Color(0xFFE8F5E9),
            'Memory performance improved by 12% over the last 7 days.',
            'Recommend increasing Memory Hunt difficulty to Level 8.',
          ),
          const SizedBox(height: 10),
          _buildInsightItem(
            Icons.track_changes,
            const Color(0xFFE53935),
            const Color(0xFFFFEBEE),
            'Attention accuracy is stable.',
            'Keep current level and continue practice.',
          ),
          const SizedBox(height: 10),
          _buildInsightItem(
            Icons.directions_run,
            const Color(0xFF1976D2),
            const Color(0xFFE3F2FD),
            'Patient is taking more time in Executive tasks.',
            'Recommend more daily routine planning activities.',
          ),
          const SizedBox(height: 10),
          _buildInsightItem(
            Icons.star_rounded,
            const Color(0xFFFFA000),
            const Color(0xFFFFF8E1),
            'Great improvement in Perceptual games!',
            'Keep up the good work.',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, Color iconColor, Color iconBg,
      String headline, String recommendation) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0ECE6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.black54,
                    height: 1.25,
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
  // FOOTER NOTE
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Note: All analytics are based on the patient\'s interactions and activities. Consistent engagement leads to better cognitive health.',
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Data last synced: 27 May 2026, 09:30 AM',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(width: 4),
          Icon(Icons.sync, size: 14, color: Color(0xFF005F46)),
        ],
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS FOR LINE CHART, DONUT CHART & BAR CHART
// =============================================================================

/// 1. Custom Multi-Line Trend Chart Painter
class _DomainTrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 35.0;
    const bottomPadding = 25.0;
    const rightPadding = 30.0;
    const topPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Y Axis Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final yValues = ['100%', '75%', '50%', '25%', '0%'];
    for (int i = 0; i < yValues.length; i++) {
      final y = topPadding + (chartHeight / (yValues.length - 1)) * i;
      canvas.drawLine(Offset(leftPadding, y),
          Offset(size.width - rightPadding, y), gridPaint);

      textPainter.text = TextSpan(
        text: yValues[i],
        style: const TextStyle(fontSize: 9, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    // X Axis Labels
    final xLabels = [
      '21 May',
      '22 May',
      '23 May',
      '24 May',
      '25 May',
      '26 May',
      '27 May'
    ];
    final stepX = chartWidth / (xLabels.length - 1);

    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPadding + stepX * i;
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(fontSize: 8.5, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 18));
    }

    // 4 Lines
    // Points are normalized 0.0 to 1.0 (0% is bottom, 100% is top)
    final memoryData = [0.70, 0.73, 0.75, 0.81, 0.80, 0.81, 0.82];
    final attentionData = [0.60, 0.63, 0.66, 0.72, 0.71, 0.73, 0.78];
    final perceptualData = [0.42, 0.46, 0.52, 0.62, 0.62, 0.66, 0.74];
    final executiveData = [0.35, 0.38, 0.40, 0.48, 0.49, 0.53, 0.70];

    _drawLine(canvas, memoryData, const Color(0xFF4CAF50), leftPadding,
        topPadding, chartHeight, stepX, '82%');
    _drawLine(canvas, attentionData, const Color(0xFF2196F3), leftPadding,
        topPadding, chartHeight, stepX, '78%');
    _drawLine(canvas, perceptualData, const Color(0xFFFF9800), leftPadding,
        topPadding, chartHeight, stepX, '74%');
    _drawLine(canvas, executiveData, const Color(0xFF9C27B0), leftPadding,
        topPadding, chartHeight, stepX, '70%');
  }

  void _drawLine(
    Canvas canvas,
    List<double> data,
    Color color,
    double leftPadding,
    double topPadding,
    double chartHeight,
    double stepX,
    String endLabel,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + stepX * i;
      final y = topPadding + chartHeight * (1.0 - data[i]);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw dots
    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + stepX * i;
      final y = topPadding + chartHeight * (1.0 - data[i]);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    // Draw end label
    final lastX = leftPadding + stepX * (data.length - 1) + 4;
    final lastY = topPadding + chartHeight * (1.0 - data.last) - 6;

    final tp = TextPainter(
      text: TextSpan(
        text: endLabel,
        style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(lastX, lastY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. Custom Donut Chart Painter
class _DonutSegment {
  final double fraction;
  final Color color;
  _DonutSegment(this.fraction, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final String centerValue;
  final String centerLabel;

  _DonutChartPainter({
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const strokeWidth = 14.0;

    var startAngle = -math.pi / 2;

    for (final seg in segments) {
      final sweepAngle = seg.fraction * 2 * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Center text
    final valPainter = TextPainter(
      text: TextSpan(
        text: centerValue,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    valPainter.paint(
      canvas,
      Offset(center.dx - (valPainter.width / 2),
          center.dy - valPainter.height / 2 - 5),
    );

    final lblPainter = TextPainter(
      text: TextSpan(
        text: centerLabel,
        style: const TextStyle(fontSize: 8.5, color: Colors.grey),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lblPainter.paint(
      canvas,
      Offset(center.dx - (lblPainter.width / 2),
          center.dy + valPainter.height / 2 - 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. Custom Bar Chart Painter
class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 30.0;
    const bottomPadding = 32.0;
    const topPadding = 16.0;
    const rightPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Y Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final yValues = ['100%', '75%', '50%', '25%', '0%'];
    for (int i = 0; i < yValues.length; i++) {
      final y = topPadding + (chartHeight / (yValues.length - 1)) * i;
      canvas.drawLine(Offset(leftPadding, y),
          Offset(size.width - rightPadding, y), gridPaint);

      textPainter.text = TextSpan(
        text: yValues[i],
        style: const TextStyle(fontSize: 8.5, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    // 5 Bars Data
    final bars = [
      _BarData('Pair\nFinder', 0.85, '85%', const Color(0xFF4CAF50)),
      _BarData('Memory\nHunt', 0.80, '80%', const Color(0xFF42A5F5)),
      _BarData('Attention\nGames', 0.78, '78%', const Color(0xFFAB47BC)),
      _BarData('Executive\nGames', 0.74, '74%', const Color(0xFFEC407A)),
      _BarData('Perceptual\nGames', 0.86, '86%', const Color(0xFFFFA726)),
    ];

    final slotWidth = chartWidth / bars.length;
    const barWidth = 24.0;

    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final centerX = leftPadding + slotWidth * i + slotWidth / 2;
      final barHeight = chartHeight * bar.fraction;
      final top = topPadding + chartHeight - barHeight;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - barWidth / 2, top, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      final paint = Paint()..color = bar.color;
      canvas.drawRRect(rrect, paint);

      // Percentage label on top of bar
      textPainter.text = TextSpan(
        text: bar.percentLabel,
        style: const TextStyle(
            fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black87),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2), top - 12),
      );

      // Category label below bar
      textPainter.text = TextSpan(
        text: bar.name,
        style: const TextStyle(fontSize: 8, color: Colors.black87, height: 1.1),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2),
            topPadding + chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarData {
  final String name;
  final double fraction;
  final String percentLabel;
  final Color color;

  _BarData(this.name, this.fraction, this.percentLabel, this.color);
}
