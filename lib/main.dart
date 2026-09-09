import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
<<<<<<< HEAD
import 'screens/games_screen.dart';
=======
import 'services/app_settings_service.dart';
>>>>>>> 132fb5e (Added FastAPI backend, MongoDB Atlas integration, login and registration)

void main() {
  runApp(const SevenSistersCare());
}

class SevenSistersCare extends StatelessWidget {
  final Widget? home;
  const SevenSistersCare({super.key, this.home});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seven Sisters Care',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D5B)),
      ),
      home: home ?? const SplashScreen(),
=======
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
              primary: const Color(0xFF005F46),
              secondary: const Color(0xFF74B49B),
              surface: const Color(0xFFF7FAF8),
            ),
            scaffoldBackgroundColor: const Color(0xFFF7FAF8),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF74B49B),
              brightness: Brightness.dark,
              primary: const Color(0xFF74B49B),
              secondary: const Color(0xFF005F46),
              surface: const Color(0xFF263238),
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
          home: const SplashScreen(),
        );
      },
>>>>>>> 132fb5e (Added FastAPI backend, MongoDB Atlas integration, login and registration)
    );
  }
}

class MyApp extends StatelessWidget {
  final Widget? home;
  const MyApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return SevenSistersCare(home: home);
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF2E7D5B),

        unselectedItemColor: Colors.grey,

        selectedFontSize: 14,

        unselectedFontSize: 13,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.games_rounded),
            label: 'Games',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Caregiver',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();

      case 1:
        return const GamesScreen();

      case 2:
        return const Center(
          child: Text(
            'Progress',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        );

      case 3:
        return const Center(
          child: Text(
            'Caregiver',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        );

      default:
        return const HomeScreen();
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seven Sisters Care',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: const Center(
        child: Text(
          'Welcome!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
