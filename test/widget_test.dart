import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seven_sisters_care/main.dart';
import 'package:seven_sisters_care/screens/splash_screen.dart';
import 'package:seven_sisters_care/screens/get_started_screen.dart';
import 'package:seven_sisters_care/screens/auth/login_signup_screen.dart';
import 'package:seven_sisters_care/screens/auth/login_screen.dart';
import 'package:seven_sisters_care/screens/registration/patient_registration_screen.dart';
import 'package:seven_sisters_care/screens/role/choose_role_screen.dart';
import 'package:seven_sisters_care/screens/patient/patient_home_screen.dart';
import 'package:seven_sisters_care/screens/caregiver/caregiver_home_screen.dart';

void main() {
  testWidgets('MainScreen loads and displays welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(const SevenSistersCare(home: MainScreen()));

    // Verify that the welcome text and title are rendered.
    expect(find.text('Seven Sisters Care'), findsWidgets);
    expect(find.text('Welcome!'), findsOneWidget);
  });

  testWidgets('App starts with SplashScreen and navigates to GetStartedScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify SplashScreen is present
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text("SEVEN SISTERS CARE"), findsOneWidget);

    // Fast forward splash timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify GetStartedScreen is displayed
    expect(find.byType(GetStartedScreen), findsOneWidget);
    expect(find.text("Get Started"), findsOneWidget);

    // Tap Get Started button
    await tester.ensureVisible(find.text("Get Started"));
    await tester.tap(find.text("Get Started"));
    await tester.pumpAndSettle();

    // Verify LoginSignupScreen is displayed
    expect(find.byType(LoginSignupScreen), findsOneWidget);
    expect(find.text("Login"), findsOneWidget);
    expect(find.text("Sign Up"), findsOneWidget);
  });

  testWidgets('LoginSignupScreen Login button navigates to LoginScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginSignupScreen(),
      ),
    );

    // Tap Login button
    await tester.tap(find.widgetWithText(ElevatedButton, "Login"));
    await tester.pumpAndSettle();

    // Verify LoginScreen is displayed
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets(
      'LoginSignupScreen Sign Up button navigates to PatientRegistrationScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginSignupScreen(),
      ),
    );

    // Tap Sign Up button
    await tester.tap(find.widgetWithText(ElevatedButton, "Sign Up"));
    await tester.pumpAndSettle();

    // Verify PatientRegistrationScreen is displayed
    expect(find.byType(PatientRegistrationScreen), findsOneWidget);
    expect(find.text("Patient Details"), findsOneWidget);
  });

  testWidgets('ChooseRoleScreen navigates to PatientHomeScreen & CaregiverHomeScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChooseRoleScreen(),
      ),
    );

    expect(find.text("Choose Your Role"), findsOneWidget);
    expect(find.text("Patient"), findsOneWidget);
    expect(find.text("Care Giver"), findsOneWidget);

    // Tap Patient button
    await tester.tap(find.widgetWithText(ElevatedButton, "Patient"));
    await tester.pumpAndSettle();

    // Verify PatientHomeScreen is displayed
    expect(find.byType(PatientHomeScreen), findsOneWidget);
    expect(find.text("Games"), findsOneWidget);
    expect(find.text("Activities"), findsOneWidget);
  });

  testWidgets('ChooseRoleScreen Care Giver button navigates to CaregiverHomeScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChooseRoleScreen(),
      ),
    );

    // Tap Care Giver button
    await tester.tap(find.widgetWithText(ElevatedButton, "Care Giver"));
    await tester.pumpAndSettle();

    // Verify CaregiverHomeScreen is displayed
    expect(find.byType(CaregiverHomeScreen), findsOneWidget);
    expect(find.text("Caregiver Portal"), findsOneWidget);
  });
}
