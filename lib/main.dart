import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

import 'screens/games_screen.dart';

import 'services/app_settings_service.dart';

void main() {
  runApp(const SevenSistersCare());
}

class SevenSistersCare extends StatelessWidget {
  final Widget? home;

  const SevenSistersCare({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService.instance,
      builder: (context, _) {
        final settings = AppSettingsService.instance;

        return MaterialApp(
          title: 'Seven Sisters Care',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF005F46),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7FAF8),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF74B49B),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF1E2623),
          ),

          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.fontScale),
              ),
              child: child!,
            );
          },

          home: home ?? const SplashScreen(),
        );
      },
    );
  }
}