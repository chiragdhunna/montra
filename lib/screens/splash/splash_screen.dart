import 'package:flutter/material.dart';
import 'package:montra/constants/montra_colors.dart';
import 'package:montra/logic/services/initialization_service.dart';
import 'package:montra/screens/on_boarding/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  void _startInitialization() async {
    final initializationService = InitializationService();

    // Listen to progress updates
    initializationService.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });

    // Await the actual initialization to complete
    await initializationService.initialise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MontraColors.splashScreenBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return RadialGradient(
                  center: Alignment.center,
                  radius: 0.3,
                  colors: [
                    Colors.pinkAccent.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: [0.1, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcOver,
              child: const Text(
                'montra',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: Colors.pinkAccent,
                ),
                const SizedBox(height: 10),
                Text(
                  "${(_progress * 100).clamp(0, 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
