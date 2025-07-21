import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'settings_screen.dart' as settings_screen;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      routes: {
        '/settings': (context) => settings_screen.SettingsScreen(toggleTheme: toggleTheme),
        '/register': (context) => RegisterScreen(toggleTheme: toggleTheme),
      },
      home: FutureBuilder<bool>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            final isLoggedIn = snapshot.data ?? false;
            return isLoggedIn
                ? HomeScreen(toggleTheme: toggleTheme)
                : LoginScreen(toggleTheme: toggleTheme);
          }
        },
      ),
    );
  }
}
