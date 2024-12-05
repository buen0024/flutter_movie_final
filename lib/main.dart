import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/share_code_screen.dart';
import 'screens/enter_code_screen.dart';
import 'screens/movie_selection_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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
        '/shareCode': (context) => ShareCodeScreen(),
        '/enterCode': (context) => EnterCodeScreen(),
        '/movieSelection': (context) => MovieSelectionScreen(),
      },
    );
  }
}
