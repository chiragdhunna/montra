import 'package:flutter/material.dart';
import 'dart:async';

class FinancialReportStatusScreen extends StatefulWidget {
  const FinancialReportStatusScreen({super.key});

  @override
  State<FinancialReportStatusScreen> createState() =>
      _FinancialReportStatusScreenState();
}

class _FinancialReportStatusScreenState
    extends State<FinancialReportStatusScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  List<double> _progressList = [0.0, 0.0, 0.0, 0.0];

  final List<Widget> _screens = [
    _buildSpendingScreen(),
    _buildIncomeScreen(),
    _buildBudgetScreen(),
    _buildQuoteScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoTransition();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoTransition() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        // Increment progress for current screen
        _progressList[_currentIndex] += 0.01;

        // If current screen's progress reaches 1.0
        if (_progressList[_currentIndex] >= 1.0) {
          // Set current screen's progress to exactly 1.0
          _progressList[_currentIndex] = 1.0;

          // Move to next screen
          if (_currentIndex < _screens.length - 1) {
            _currentIndex++;
            // Don't automatically advance to the next screen if we're at the last screen
          } else {
            // If at last screen, stop the timer
            _timer?.cancel();
          }
        }
      });
    });
  }

  void _nextScreen() {
    if (_currentIndex < _screens.length - 1) {
      _timer?.cancel(); // Cancel auto transition

      setState(() {
        // Complete the current screen progress
        _progressList[_currentIndex] = 1.0;

        // Move to next screen
        _currentIndex++;
      });

      _startAutoTransition(); // Restart auto transition
    }
  }

  void _previousScreen() {
    if (_currentIndex > 0) {
      _timer?.cancel(); // Cancel auto transition

      setState(() {
        // Reset the current screen progress
        _progressList[_currentIndex] = 0.0;

        // Move to previous screen
        _currentIndex--;

        // Make sure we restart the progress for the previous screen
        // if it's already completed
        if (_progressList[_currentIndex] >= 1.0) {
          _progressList[_currentIndex] = 0.0;
        }
      });

      // Always restart auto transition for the previous screen
      _startAutoTransition();
    }
  }

  // Add a method to reset all progress bars
  void _resetAllProgress() {
    setState(() {
      // Reset all progress bars
      for (int i = 0; i < _progressList.length; i++) {
        _progressList[i] = 0.0;
      }
      // Set current index to 0 (first screen)
      _currentIndex = 0;
    });
    _startAutoTransition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                _previousScreen();
              } else if (details.primaryVelocity! < 0) {
                _nextScreen();
              }
            },
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.localPosition.dx < screenWidth * 0.2) {
                _previousScreen();
              } else if (details.localPosition.dx > screenWidth * 0.2) {
                _nextScreen();
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_currentIndex],
            ),
          ),

          // Progress bars overlay at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Row(
                children:
                    List.generate(_progressList.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressList[index],
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSpendingScreen() {
  return Container(
    key: const ValueKey('spending'),
    color: Colors.red,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "This Month",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "You Spend 💸",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "\$332",
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "and your biggest spending is from",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Chip(
                  label: const Text("Shopping"),
                  backgroundColor: Colors.orange.withOpacity(0.2),
                ),
                const SizedBox(height: 5),
                const Text(
                  "\$120",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildIncomeScreen() {
  return Container(
    key: const ValueKey('income'),
    color: Colors.green,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "This Month",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "You Earned 💰",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "\$6000",
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Your biggest income is from",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Chip(
                  label: const Text("Salary"),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
                const SizedBox(height: 5),
                const Text(
                  "\$5000",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBudgetScreen() {
  return Container(
    key: const ValueKey('budget'),
    color: Colors.purple,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "This Month",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "2 of 12 Budgets exceed the limit",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(
                label: const Text("Shopping"),
                backgroundColor: Colors.orange.withOpacity(0.2),
              ),
              const SizedBox(width: 10),
              Chip(
                label: const Text("Food"),
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildQuoteScreen() {
  return Container(
    key: const ValueKey('quote'),
    color: Colors.purple,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Financial freedom is freedom from fear.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "- Robert Kiyosaki",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "See the full detail",
              style: TextStyle(color: Colors.purple, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
