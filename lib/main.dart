import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/games_screen.dart';

void main() {
  runApp(const SevenSistersCare());
}

class SevenSistersCare extends StatelessWidget {
  final Widget? home;
  const SevenSistersCare({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seven Sisters Care',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D5B)),
      ),
      home: home ?? const SplashScreen(),
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
