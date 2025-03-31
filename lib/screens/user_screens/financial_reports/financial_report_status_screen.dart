import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/blocs/expense/expense_bloc.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';
import 'dart:async';

import 'package:montra/screens/user_screens/financial_reports/financial_report_screen.dart';

Logger log = Logger(printer: PrettyPrinter());

class FinancialReportStatusScreen extends StatefulWidget {
  const FinancialReportStatusScreen({super.key});

  @override
  State<FinancialReportStatusScreen> createState() =>
      _FinancialReportStatusScreenState();
}

class _FinancialReportStatusScreenState
    extends State<FinancialReportStatusScreen> {
  late StreamSubscription<IncomeState> _incomeStreamSubscription;
  late StreamSubscription<ExpenseState> _expenseStreamSubscription;
  int _currentIndex = 0;
  Timer? _timer;
  final List<double> _progressList = [0.0, 0.0, 0.0, 0.0];
  bool _isIncomeLoading = true;
  bool _isExpensesLoading = true;
  bool _isPaused = false;
  bool _isLongPressing = false; // Track when long press is active
  int totalIncome = 0;
  int totalExpense = 0;
  int totalBalance = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<IncomeBloc>(context).add(IncomeEvent.getIncome());
    BlocProvider.of<ExpenseBloc>(context).add(ExpenseEvent.getExpense());
    incomeBlocChangeHandler(BlocProvider.of<IncomeBloc>(context).state);
    expenseBlocChangeHandler(BlocProvider.of<ExpenseBloc>(context).state);
    _screens = [
      _buildSpendingScreen(),
      _buildIncomeScreen(),
      _buildBudgetScreen(),
      _buildQuoteScreen(),
    ];
    _startAutoTransition();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void incomeBlocChangeHandler(IncomeState state) {
    state.maybeWhen(
      orElse: () {
        log.d('State is or else');
      },
      getWalletNamesSuccess: (walletNames) {
        setState(() {
          _isIncomeLoading = false;
        });
      },
      getIncomeSuccess: (income) {
        log.d('State is getIncomeSuccess');
        if (!mounted) return;
        setState(() {
          totalIncome = income;
          _isIncomeLoading = false;
        });
      },
      failure: () {
        log.d('State is failure');
        if (!mounted) return;
        setState(() {
          _isIncomeLoading = false;
        });
      },
      inProgress: () {
        log.d('State is inProgress');
        if (!mounted) return;
        setState(() {
          _isIncomeLoading = true;
        });
      },
      setIncomeSuccess: () {
        log.d('State is setIncomeSuccess');
        if (!mounted) return;
        setState(() {
          _isIncomeLoading = false;
        });
      },
      createIncomeSuccess: () {
        _isIncomeLoading = false;
        BlocProvider.of<IncomeBloc>(context).add(IncomeEvent.getIncome());
      },
    );
  }

  void expenseBlocChangeHandler(ExpenseState state) {
    state.maybeWhen(
      orElse: () {
        log.d('State is or else');
      },
      getExpenseSuccess: (expense, expenseData) {
        log.d('State is getExpenseSuccess');
        if (!mounted) return;
        setState(() {
          totalExpense = expense;
          _isExpensesLoading = false;
        });
      },
      failure: (error) {
        log.d('State is failure');
        if (!mounted) return;
        setState(() {
          _isExpensesLoading = false;
        });
      },
      inProgress: () {
        log.d('State is inProgress');
        if (!mounted) return;
        setState(() {
          _isExpensesLoading = true;
        });
      },
      setExpenseSuccess: () {
        log.d('State is setExpenseSuccess');
        if (!mounted) return;
        setState(() {
          _isExpensesLoading = false;
        });
      },
      createExpenseSuccess: () {
        _isExpensesLoading = false;
        BlocProvider.of<ExpenseBloc>(context).add(ExpenseEvent.getExpense());
      },
    );
  }

  void _startAutoTransition() {
    _timer?.cancel();

    if (!_isPaused) {
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
            } else {
              // If at last screen, stop the timer
              _timer?.cancel();
            }
          }
        });
      });
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
      } else {
        _startAutoTransition();
      }
    });
  }

  void _nextScreen() {
    // Do nothing if we're in a long press or paused
    if (_isLongPressing || _isPaused) return;

    if (_currentIndex < _screens.length - 1) {
      _timer?.cancel();

      setState(() {
        _progressList[_currentIndex] = 1.0;
        _currentIndex++;
      });

      _startAutoTransition();
    }
  }

  void _previousScreen() {
    // Do nothing if we're in a long press or paused
    if (_isLongPressing || _isPaused) return;

    if (_currentIndex > 0) {
      _timer?.cancel();

      setState(() {
        _progressList[_currentIndex] = 0.0;
        _currentIndex--;

        if (_progressList[_currentIndex] >= 1.0) {
          _progressList[_currentIndex] = 0.0;
        }
      });

      _startAutoTransition();
    }
  }

  // Add a method to reset all progress bars
  void _resetAllProgress() {
    setState(() {
      for (int i = 0; i < _progressList.length; i++) {
        _progressList[i] = 0.0;
      }
      _currentIndex = 0;
      _isPaused = false;
    });
    _startAutoTransition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content - Use RawGestureDetector to have more control
          Listener(
            onPointerDown: (PointerDownEvent event) {
              // Start tracking potential long press
            },
            onPointerUp: (PointerUpEvent event) {
              // End tracking potential long press
            },
            child: GestureDetector(
              // This will ensure long press takes precedence over taps
              onLongPressStart: (LongPressStartDetails details) {
                setState(() {
                  _isLongPressing = true;
                });
              },
              onLongPress: () {
                _togglePause();
              },
              onLongPressEnd: (LongPressEndDetails details) {
                setState(() {
                  _isLongPressing = false;
                });
              },
              // Disable tap functionality while long pressing
              onTapDown: (TapDownDetails details) {
                if (_isLongPressing || _isPaused) return;

                final screenWidth = MediaQuery.of(context).size.width;
                if (details.localPosition.dx < screenWidth * 0.2) {
                  _previousScreen();
                } else if (details.localPosition.dx > screenWidth * 0.8) {
                  _nextScreen();
                }
              },
              // Disable drag functionality while long pressing
              onHorizontalDragEnd: (DragEndDetails details) {
                if (_isLongPressing || _isPaused) return;

                if (details.primaryVelocity! > 0) {
                  _previousScreen();
                } else if (details.primaryVelocity! < 0) {
                  _nextScreen();
                }
              },
              child: Stack(
                children: [
                  // Current screen
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _screens[_currentIndex],
                  ),

                  // Pause overlay
                  if (_isPaused)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pause_circle_filled,
                                size: 80,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Paused",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _togglePause,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Resume",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
            Text(
              "\$$totalExpense",
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
            Text(
              "\$$totalIncome",
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => FinancialReportScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
}
