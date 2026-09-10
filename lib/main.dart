import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'localization/app_localizations.dart';
import 'providers/language_provider.dart';
import 'services/language_service.dart';
import 'services/app_settings_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageService = LanguageService.instance;
  await languageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(languageService),
      child: const SevenSistersCare(),
    ),
  );
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
        final languageProvider = context.watch<LanguageProvider>();

        return MaterialApp(
          title: 'Seven Sisters Care',
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          debugShowCheckedModeBanner: false,
          locale: languageProvider.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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