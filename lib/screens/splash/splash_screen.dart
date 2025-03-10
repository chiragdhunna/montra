import 'package:flutter/material.dart';
import 'package:montra/constants/montra_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MontraColors.splashScreenBackgroundColor, // Purple background
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
              child: Text(
                'montra',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
