import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/screens/caregiver/caregiver_dashboard.dart';
import 'package:seven_sisters_care/screens/caregiver/caregiver_analytics_dashboard.dart';

void main() {
  testWidgets('CaregiverDashboard displays sidebar items and report generator',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverDashboard(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify sidebar items
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Remainder'), findsWidgets);
    expect(find.text('Games'), findsWidgets);
    expect(find.text('Activities'), findsWidgets);
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // Verify sections on dashboard
    expect(find.text('Patient Name'), findsOneWidget);
    expect(find.text('Remainder Notifications'), findsOneWidget);
    expect(find.text('Memory Engaging Activities'), findsOneWidget);
    expect(find.text('Cognitive Games'), findsOneWidget);
    expect(find.text('Report Generator'), findsOneWidget);

    // Verify report generator basis options
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);

    // Switch to Monthly
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.text('Export as PDF'), findsOneWidget);
  });

  testWidgets(
      'Navigating to Analytics Dashboard and back to Dashboard works properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverDashboard(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Analytics in sidebar
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    // Should now be on CaregiverAnalyticsDashboard
    expect(find.byType(CaregiverAnalyticsDashboard), findsOneWidget);
    expect(find.text('Analytics Dashboard'), findsOneWidget);
    expect(find.text('Lakshmi Devi'), findsOneWidget);
    expect(find.text('Overall Cognitive Score'), findsOneWidget);
    expect(find.text('80%'), findsWidgets);
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('Average Accuracy'), findsOneWidget);
    expect(find.text('82%'), findsWidgets);
    expect(find.text('1. Domain Performance Trend (Last 7 Days)'), findsOneWidget);
    expect(find.text('2. Reminder Compliance'), findsOneWidget);
    expect(find.text('4. Game Wise Performance'), findsOneWidget);
    expect(find.text('AI Insights & Recommendations'), findsOneWidget);

    // Tap Dashboard on sidebar to return to CaregiverDashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(CaregiverDashboard), findsOneWidget);
  });
}
