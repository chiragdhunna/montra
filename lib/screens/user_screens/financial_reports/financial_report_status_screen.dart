import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:montra/constants/quotes.dart';
import 'package:montra/logic/blocs/expense/expense_bloc.dart';
import 'package:montra/logic/blocs/financial_status_bloc/financial_status_bloc.dart';
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
  late StreamSubscription<FinancialStatusState>
  _financialStatusStreamSubscription;
  FinancialStatusState _financialStatusState = FinancialStatusState.initial();

  late StreamSubscription<IncomeState> _incomeStreamSubscription;
  late StreamSubscription<ExpenseState> _expenseStreamSubscription;

  Map<String, dynamic>? biggestIncomeSource;
  Map<String, dynamic>? biggestExpenseSource;
  int numberOfBudgetsExceeded = 0;
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
    _financialStatusStreamSubscription = BlocProvider.of<FinancialStatusBloc>(
      context,
    ).stream.listen(_onFinancialStatusStateChanged);
    _incomeStreamSubscription = BlocProvider.of<IncomeBloc>(
      context,
    ).stream.listen(incomeBlocChangeHandler);
    _expenseStreamSubscription = BlocProvider.of<ExpenseBloc>(
      context,
    ).stream.listen(expenseBlocChangeHandler);

    BlocProvider.of<IncomeBloc>(context).add(IncomeEvent.getIncome());
    BlocProvider.of<ExpenseBloc>(context).add(ExpenseEvent.getExpense());
    BlocProvider.of<FinancialStatusBloc>(context).add(LoadFinancialStatus());
    incomeBlocChangeHandler(BlocProvider.of<IncomeBloc>(context).state);
    expenseBlocChangeHandler(BlocProvider.of<ExpenseBloc>(context).state);
    _onFinancialStatusStateChanged(
      BlocProvider.of<FinancialStatusBloc>(context).state,
    );
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
    _financialStatusStreamSubscription.cancel();
    _incomeStreamSubscription.cancel();
    _expenseStreamSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _onFinancialStatusStateChanged(FinancialStatusState state) {
    if (!mounted) return;

    setState(() {
      _financialStatusState = state;
      if (state.status == FinancialStatus.loaded) {
        // Add debug print to verify values before assignment
        print(
          "Setting sources: income=${state.biggestIncomeSource}, expense=${state.biggestExpenseSource}",
        );

        biggestIncomeSource = state.biggestIncomeSource;
        biggestExpenseSource = state.biggestExpenseSource;
        numberOfBudgetsExceeded = state.numberOfBudgetsExceeded;

        log.d(
          'biggestIncomeSource : $biggestIncomeSource , biggestExpenseSource : $biggestExpenseSource , numberOfBudgetsExceeded : $numberOfBudgetsExceeded state is $state',
        );

        _screens = [
          _buildSpendingScreen(),
          _buildIncomeScreen(),
          _buildBudgetScreen(),
          _buildQuoteScreen(),
        ];
      }
    });
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
                  _isPaused = true;
                  _timer?.cancel();
                });
              },
              onLongPressEnd: (LongPressEndDetails details) {
                setState(() {
                  _isLongPressing = false;
                  _isPaused = false;
                  _startAutoTransition(); // Resume when long press ends
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
    log.d('incomeSource right now : $biggestIncomeSource');

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
                    "and your biggest income is from",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  // Check if biggestIncomeSource is available, else show a loading state or placeholder
                  biggestIncomeSource != null
                      ? Chip(
                        label: Text(
                          biggestIncomeSource!['source'], // Dynamically display the source name
                        ),
                        backgroundColor: Colors.green.withOpacity(
                          0.2,
                        ), // You can change the color based on the source
                      )
                      : const CircularProgressIndicator(), // Show a loading spinner while data is being fetched
                  const SizedBox(height: 5),
                  biggestIncomeSource != null
                      ? Text(
                        "\$${biggestIncomeSource!['amount']}", // Dynamically display the amount
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : const SizedBox.shrink(), // Show nothing until the data is fetched
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
                    "Your biggest expense is from",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  // Check if biggestExpenseSource is available, else show a loading state or placeholder
                  biggestExpenseSource != null
                      ? Chip(
                        label: Text(
                          biggestExpenseSource!['source'], // Dynamically display the source name
                        ),
                        backgroundColor: Colors.red.withOpacity(
                          0.2,
                        ), // You can change the color based on the source
                      )
                      : const CircularProgressIndicator(), // Show a loading spinner while data is being fetched
                  const SizedBox(height: 5),
                  biggestExpenseSource != null
                      ? Text(
                        "\$${biggestExpenseSource!['amount']}", // Dynamically display the amount
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : const SizedBox.shrink(), // Show nothing until the data is fetched
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
            Text(
              "$numberOfBudgetsExceeded of 12 Budgets exceed the limit",
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
    // Select a random quote from the list
    final randomQuote = (quotes..shuffle()).first;

    return Container(
      key: const ValueKey('quote'),
      color: Colors.purple,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              randomQuote.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "- ${randomQuote.author}",
              style: const TextStyle(fontSize: 16, color: Colors.white),
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
