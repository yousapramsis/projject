import 'package:flutter/material.dart';

import '../Diseases/Diabetes/diabetes_test_page.dart';
import '../Home/home_page.dart';


class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash_screen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Navigate to home screen after delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement( // Use pushReplacement instead of push
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    title: 'Multiple Disease App',
                  )));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Add this line
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6565FB), Color(0xFF8A8AFF)],
          ),
        ),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Heart with pulse logo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Heart shape using custom painter
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: HeartPainter(),
                      ),
                    ),
                    // Pulse line
                    SizedBox(
                      width: 100,
                      height: 60,
                      child: CustomPaint(
                        painter: PulsePainter(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // App name
                const Text(
                  'Health Guardian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Tagline
                const Text(
                  'Early Detection Saves Lives',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                // Loading indicator
                const LoadingDots(),
                const SizedBox(height: 100),
                // Bottom text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'The greatest wealth is health.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for the heart shape
class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFFF5757)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double width = size.width;
    final double height = size.height;

    path.moveTo(width * 0.5, height * 0.25);
    path.cubicTo(width * 0.5 - 15, height * 0.1, width * 0.2, height * 0.1,
        width * 0.35, height * 0.4);
    path.cubicTo(width * 0.33, height * 0.5, width * 0.4, height * 0.7,
        width * 0.5, height * 0.75);
    path.cubicTo(width * 0.6, height * 0.7, width * 0.67, height * 0.5,
        width * 0.65, height * 0.4);
    path.cubicTo(width * 0.8, height * 0.1, width * 0.5 + 15, height * 0.1,
        width * 0.5, height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for pulse line
class PulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final double width = size.width;
    final double height = size.height;

    path.moveTo(0, height / 2);
    path.lineTo(width * 0.3, height / 2);
    path.lineTo(width * 0.4, height * 0.3);
    path.lineTo(width * 0.6, height * 0.7);
    path.lineTo(width * 0.7, height / 2);
    path.lineTo(width, height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated loading dots
class LoadingDots extends StatefulWidget {
  const LoadingDots({Key? key}) : super(key: key);

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double opacity =
                ((_controller.value + (index * 0.3)) % 1.0) < 0.5
                    ? ((_controller.value + (index * 0.3)) % 1.0) * 2
                    : (1.0 - ((_controller.value + (index * 0.3)) % 1.0)) * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3 + (opacity * 0.7)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

