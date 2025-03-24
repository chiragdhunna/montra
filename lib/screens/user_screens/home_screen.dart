import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/expense/models/expense_frequency_data_set_model.dart';
import 'package:montra/logic/api/expense/models/expense_stats_frequency_model.dart';
import 'package:montra/logic/api/expense/models/expense_stats_model.dart';
import 'package:montra/logic/api/expense/models/expense_stats_summary_model.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/logic/blocs/expense/expense_bloc.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';
import 'package:montra/logic/blocs/transactions_bloc/transactions_bloc.dart';
import 'package:montra/screens/notification/notification_screen.dart';
import 'package:montra/screens/user_screens/transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Logger log = Logger(printer: PrettyPrinter());

class _HomeScreenState extends State<HomeScreen> {
  List<Color> gradientColors = [
    Colors.deepPurpleAccent,
    Colors.deepPurpleAccent,
  ];

  List<Map<String, dynamic>> recentTransactions = [];

  late StreamSubscription<IncomeState> _incomeStreamSubscription;
  late StreamSubscription<ExpenseState> _expenseStreamSubscription;
  late StreamSubscription<TransactionsState> _transactionsStreamSubscription;
  bool _isIncomeLoading = true;
  int totalIncome = 0;
  int totalExpense = 0;
  String selectedFilter = "Today";
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  String selectedMonth = "";

  ExpenseStatsModel expenseStats = ExpenseStatsModel(
    summary: ExpenseStatsSummaryModel(today: 0, week: 0, month: 0, year: 0),
    frequency: ExpenseStatsFrequencyModel(
      today: [ExpenseFrequencyDataSetModel(label: "label", total: 0)],
      week: [ExpenseFrequencyDataSetModel(label: "label", total: 0)],
      month: [ExpenseFrequencyDataSetModel(label: "label", total: 0)],
      year: [ExpenseFrequencyDataSetModel(label: "label", total: 0)],
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    selectedMonth = months[DateTime.now().month - 1];
    BlocProvider.of<IncomeBloc>(context).add(IncomeEvent.getIncome());
    BlocProvider.of<ExpenseBloc>(context).add(ExpenseEvent.getExpense());
    BlocProvider.of<TransactionsBloc>(
      context,
    ).add(TransactionsEvent.getAllTransactions());
    _incomeStreamSubscription = BlocProvider.of<IncomeBloc>(
      context,
    ).stream.listen(incomeBlocChangeHandler);
    _expenseStreamSubscription = BlocProvider.of<ExpenseBloc>(
      context,
    ).stream.listen(expenseBlocChangeHandler);
    _transactionsStreamSubscription = BlocProvider.of<TransactionsBloc>(
      context,
    ).stream.listen(transactionsBlocChangeHandler);

    incomeBlocChangeHandler(BlocProvider.of<IncomeBloc>(context).state);
    expenseBlocChangeHandler(BlocProvider.of<ExpenseBloc>(context).state);
    transactionsBlocChangeHandler(
      BlocProvider.of<TransactionsBloc>(context).state,
    );

    super.initState();
  }

  void incomeBlocChangeHandler(IncomeState state) {
    state.maybeWhen(
      orElse: () {},
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
    );
  }

  void expenseBlocChangeHandler(ExpenseState state) {
    state.maybeWhen(
      orElse: () {},
      getExpenseSuccess: (expense, expenseData) {
        log.d('State is getExpenseSuccess');
        if (!mounted) return;
        setState(() {
          totalExpense = expense;
          expenseStats = expenseData;
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
      setExpenseSuccess: () {
        log.d('State is setExpenseSuccess');
        if (!mounted) return;
        setState(() {
          _isIncomeLoading = false;
        });
      },
    );
  }

  void transactionsBlocChangeHandler(TransactionsState state) {
    state.maybeWhen(
      orElse: () {},
      getAllTransactionSuccess: (transactions) {
        if (!mounted) return;
        setState(() {
          // Store the most recent transactions (e.g., the first 3)
          recentTransactions =
              transactions
                  .take(3)
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
          _isIncomeLoading = false;
          log.w('Transactions from recentTransactions : $recentTransactions');
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
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _incomeStreamSubscription.cancel();
    _expenseStreamSubscription.cancel();
    _transactionsStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            _isIncomeLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Change this line in the Header Section
                            CircleAvatar(
                              radius: 20.r,
                              backgroundImage:
                                  widget.user.imgUrl != null &&
                                          widget.user.imgUrl!.isNotEmpty
                                      ? widget.user.imgUrl!.startsWith('/')
                                          ? FileImage(File(widget.user.imgUrl!))
                                              as ImageProvider
                                          : AssetImage(widget.user.imgUrl!)
                                      : AssetImage("assets/default_avatar.png"),
                            ),
                            Center(
                              child: PopupMenuButton<String>(
                                onSelected: (value) {
                                  setState(() {
                                    selectedMonth = value;
                                  });
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem<String>(
                                      enabled: false,
                                      child: SizedBox(
                                        width: 200.w, // Width of popup
                                        height: 250.h, // Height for scroll
                                        child: Scrollbar(
                                          thickness: 4,
                                          radius: Radius.circular(10),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: months.length,
                                            itemBuilder: (context, index) {
                                              final month = months[index];
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    selectedMonth = month;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 10.h,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      month,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            month ==
                                                                    selectedMonth
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        color:
                                                            month ==
                                                                    selectedMonth
                                                                ? Colors.blue
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                offset: Offset(
                                  -75.w,
                                  40.h,
                                ), // Adjust first value to shift left/right
                                // 👇 THIS makes the dropdown appear centered under the button
                                position: PopupMenuPosition.under,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        selectedMonth,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (builder) => NotificationScreen(),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.notifications,
                                size: 24.r,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Account Balance
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Account Balance",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                "\$$totalExpense",
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Income & Expenses Cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildIncomeExpenseCard(
                              "Income",
                              "\$$totalIncome",
                              Colors.green,
                            ),
                            _buildIncomeExpenseCard(
                              "Expenses",
                              "\$$totalExpense",
                              Colors.red,
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Spend Frequency Chart
                        Text(
                          "Spend Frequency",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        _buildLineChart(
                          selectedFilter == "Today"
                              ? expenseStats.frequency.today
                              : selectedFilter == "Month"
                              ? expenseStats.frequency.month
                              : selectedFilter == "Year"
                              ? expenseStats.frequency.year
                              : expenseStats.frequency.week,
                        ),
                        SizedBox(height: 10.h),

                        // Time Filters
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFilterChip(
                              "Today",
                              isSelected: selectedFilter == "Today",
                            ),
                            _buildFilterChip(
                              "Week",
                              isSelected: selectedFilter == "Week",
                            ),
                            _buildFilterChip(
                              "Month",
                              isSelected: selectedFilter == "Month",
                            ),
                            _buildFilterChip(
                              "Year",
                              isSelected: selectedFilter == "Year",
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Recent Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Transaction",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (builder) => TransactionScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "See All",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Transactions List
                        // _buildTransactionTile(
                        //   "Shopping",
                        //   "Buy some grocery",
                        //   "-\$120",
                        //   Colors.orange,
                        //   "assets/shopping.png",
                        // ),
                        // _buildTransactionTile(
                        //   "Subscription",
                        //   "Disney+ Annual..",
                        //   "-\$80",
                        //   Colors.purple,
                        //   "assets/subscription.png",
                        // ),
                        // _buildTransactionTile(
                        //   "Food",
                        //   "Buy a ramen",
                        //   "-\$32",
                        //   Colors.red,
                        //   "assets/food.png",
                        // ),
                        recentTransactions.isEmpty
                            ? Center(
                              child: Text(
                                "No recent transactions",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : Column(
                              children:
                                  recentTransactions.map((transaction) {
                                    String title = "";
                                    String subtitle = "";
                                    String amount = "";
                                    Color iconColor = Colors.grey;
                                    String imagePath = "assets/default.png";

                                    // Determine transaction type and set properties accordingly
                                    if (transaction['type'] == 'expense') {
                                      final expense = transaction['data'];
                                      title =
                                          expense.source
                                              .toString()
                                              .split('.')
                                              .last;
                                      subtitle = expense.description;
                                      amount = "-\$${expense.amount}";
                                      iconColor = Colors.red;
                                      imagePath =
                                          "assets/expense.png"; // Use appropriate image
                                    } else if (transaction['type'] ==
                                        'income') {
                                      final income = transaction['data'];
                                      title =
                                          income.source
                                              .toString()
                                              .split('.')
                                              .last;
                                      subtitle = income.description ?? "Income";
                                      amount = "+\$${income.amount}";
                                      iconColor = Colors.green;
                                      imagePath =
                                          "assets/income.png"; // Use appropriate image
                                    } else {
                                      final transfer = transaction['data'];
                                      title = "Transfer";
                                      subtitle =
                                          "From ${transfer.sender} to ${transfer.receiver}";
                                      amount =
                                          transfer.isExpense
                                              ? "-\$${transfer.amount}"
                                              : "+\$${transfer.amount}";
                                      iconColor = Colors.blue;
                                      imagePath =
                                          "assets/transfer.png"; // Use appropriate image
                                    }

                                    return _buildTransactionTile(
                                      title,
                                      subtitle,
                                      amount,
                                      iconColor,
                                      imagePath,
                                    );
                                  }).toList(),
                            ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildIncomeExpenseCard(String title, String amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      width: 154.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: color,
            child: const Icon(Icons.attach_money, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, color: Colors.black54),
              ),
              Text(
                amount,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<ExpenseFrequencyDataSetModel> data) {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].total.toDouble()));
    }

    return SizedBox(
      height: 150.h,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),

          lineBarsData: [
            LineChartBarData(
              // spots: [
              //   const FlSpot(0, 1),
              //   const FlSpot(1, 3),
              //   const FlSpot(2, 2),
              //   const FlSpot(3, 4),
              //   const FlSpot(4, 3),
              //   const FlSpot(5, 5),
              //   const FlSpot(6, 4),
              // ],
              spots: spots,
              isCurved: true,
              color: Colors.purple,

              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors:
                      gradientColors
                          .map((color) => color.withValues(alpha: 0.3))
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    String title,
    String subtitle,
    String amount,
    Color iconColor,
    String imagePath,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5.r, spreadRadius: 1.r),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Image.asset(imagePath),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
