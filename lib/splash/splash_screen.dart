// lib/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:project_grad/Home/home_page.dart' show MyHomePage;

class SplashScreen extends StatefulWidget {
  final Locale currentLocale;
  final Function(Locale) onLocaleChange;

  const SplashScreen({
    Key? key,
    required this.currentLocale,
    required this.onLocaleChange,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          currentLocale: widget.currentLocale,
          onLocaleChange: widget.onLocaleChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon or logo
              const Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 32),
              // App title
              Text(
                "Multiple Disease App",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Optional: Subtitle
              Text(
                "Predict your diseases properly",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
