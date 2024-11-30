import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Night!',
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
      },
    );
  }
}
