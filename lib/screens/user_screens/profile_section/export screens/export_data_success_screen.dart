import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/blocs/export_data/export_data_bloc.dart';
import 'package:montra/screens/user_screens/home_screen.dart';
import 'package:montra/screens/user_screens/profile_screen.dart';

class ExportDataSuccessScreen extends StatefulWidget {
  const ExportDataSuccessScreen({super.key});

  @override
  State<ExportDataSuccessScreen> createState() =>
      _ExportDataSuccessScreenState();
}

class _ExportDataSuccessScreenState extends State<ExportDataSuccessScreen> {
  @override
  void initState() {
    // TODO: implement initState
    BlocProvider.of<ExportDataBloc>(context).add(ExportDataEvent.showFile());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tilted spreadsheet icon
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Center(
                        child: Transform.rotate(
                          angle:
                              -math.pi /
                              8, // Adjusted tilt angle (about 22.5 degrees)
                          child: CustomPaint(
                            size: Size(100, 100),
                            painter: SpreadsheetPainter(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Message text
                    Text(
                      'Check your email, we send you the financial report. In certain cases, it might take a little longer, depending on the time period and the volume of activity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Back to Home button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to home
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade500,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            // Bottom indicator
            Container(
              width: 40,
              height: 5,
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the spreadsheet icon
class SpreadsheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define colors
    final Color borderColor = Color(
      0xFFB388FF,
    ); // Slightly darker purple for border
    final Color darkCellColor = Color(
      0xFFD1C4E9,
    ); // Dark purple for first row and column
    final Color lightCellColor = Color(
      0xFFF3E5F5,
    ); // Light purple for other cells

    final Paint borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final Paint darkCellPaint =
        Paint()
          ..color = darkCellColor
          ..style = PaintingStyle.fill;

    final Paint lightCellPaint =
        Paint()
          ..color = lightCellColor
          ..style = PaintingStyle.fill;

    // Calculate cell dimensions
    final double cellWidth = size.width / 3;
    final double cellHeight = size.height / 3;

    // Draw rounded rectangle for the entire grid with more rounded corners
    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.2), // More rounded corners
    );

    // First fill the entire grid with dark purple
    canvas.drawRRect(roundedRect, darkCellPaint);

    // Draw light cells (all except first row and first column)
    for (int row = 1; row < 3; row++) {
      for (int col = 1; col < 3; col++) {
        final RRect cellRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(
            col * cellWidth,
            row * cellHeight,
            cellWidth,
            cellHeight,
          ),
          topRight:
              col == 2 && row == 0
                  ? Radius.circular(size.width * 0.2)
                  : Radius.zero,
          bottomRight:
              col == 2 && row == 2
                  ? Radius.circular(size.width * 0.2)
                  : Radius.zero,
          bottomLeft:
              col == 0 && row == 2
                  ? Radius.circular(size.width * 0.2)
                  : Radius.zero,
        );
        canvas.drawRect(cellRect.outerRect, lightCellPaint);
      }
    }

    // Draw vertical grid lines
    for (int i = 1; i <= 2; i++) {
      final double x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), borderPaint);
    }

    // Draw horizontal grid lines
    for (int i = 1; i <= 2; i++) {
      final double y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), borderPaint);
    }

    // Draw the outer border with rounded corners
    canvas.drawRRect(roundedRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
