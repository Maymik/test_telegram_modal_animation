import 'package:flutter/material.dart';
import 'package:test_telegram_modal_animation/ui/home_screen.dart';
import 'package:test_telegram_modal_animation/ui/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test TMA Modal Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
