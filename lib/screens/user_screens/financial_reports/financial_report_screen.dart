import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/blocs/financial_report_bloc/financial_report_bloc.dart'; // Import the new FinancialReportBloc

Logger log = Logger(printer: PrettyPrinter());

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  late StreamSubscription<FinancialReportState>
  _financialReportStreamSubscription;
  bool isExpenseSelected = true;
  bool isGraphSelected = true;
  String selectedTransactionType = "Category";
  String selectedCategory = "Category";
  String selectedTimeFilter = "Month";
  bool _isIncomeLoading = true;
  bool _isExpensesLoading = true;
  int totalIncome = 0;
  int totalExpense = 0;
  int totalBalance = 0;

  // Add these properties for storing statistics
  List<Map<String, dynamic>> _incomeBreakdown = [];
  List<Map<String, dynamic>> _expenseBreakdown = [];
  Map<String, dynamic>? _financeStats;

  @override
  void initState() {
    super.initState();
    // Subscribe to the FinancialReportBloc stream
    _financialReportStreamSubscription = BlocProvider.of<FinancialReportBloc>(
      context,
    ).stream.listen(_financialReportBlocStateHandler);

    // Dispatch the event to load data
    BlocProvider.of<FinancialReportBloc>(
      context,
    ).add(FinancialReportEvent.loadFinancialReport());
  }

  // Stream handler for the FinancialReportBloc
  void _financialReportBlocStateHandler(FinancialReportState state) {
    state.maybeWhen(
      loading: () {
        setState(() {
          _isIncomeLoading = true;
          _isExpensesLoading = true;
        });
      },
      loaded: (
        totalIncome,
        totalExpense,
        totalBalance,
        incomeBreakdown,
        expenseBreakdown,
        financeStats,
      ) {
        setState(() {
          this.totalIncome = totalIncome;
          this.totalExpense = totalExpense;
          this.totalBalance = totalBalance;
          _incomeBreakdown = incomeBreakdown;
          _expenseBreakdown = expenseBreakdown;
          _financeStats = financeStats;
          _isIncomeLoading = false;
          _isExpensesLoading = false;
        });
      },
      failure: (error) {
        setState(() {
          _isIncomeLoading = false;
          _isExpensesLoading = false;
        });
        log.e('Error loading financial data: $error');
      },
      orElse: () {},
    );
  }

  @override
  void dispose() {
    _financialReportStreamSubscription
        .cancel(); // Cancel the subscription when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Report"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isIncomeLoading || _isExpensesLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection(),
                      SizedBox(height: 10.h),
                      _buildGraph(),
                      SizedBox(height: 20.h),
                      _buildToggleButtons(),
                      SizedBox(height: 10.h),
                      _buildTransactionFilters(),
                      SizedBox(height: 10.h),
                      _buildTransactionList(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: selectedTimeFilter,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.purple),
          items:
              ["Week", "Month", "Year"]
                  .map(
                    (filter) =>
                        DropdownMenuItem(value: filter, child: Text(filter)),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              selectedTimeFilter = value!;
              // Dispatch the event to update the financial report with the new time filter
              BlocProvider.of<FinancialReportBloc>(
                context,
              ).add(FinancialReportEvent.loadFinancialReport());
            });
          },
          underline: Container(),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.show_chart,
                color: isGraphSelected ? Colors.purple : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  isGraphSelected = true;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.pie_chart,
                color: !isGraphSelected ? Colors.purple : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  isGraphSelected = false;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGraph() {
    if (isGraphSelected) {
      return Column(
        children: [
          Text(
            "\$${isExpenseSelected ? totalExpense : totalIncome}",
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 180.h,
            child: _buildLineChart(),
          ), // Fixed: _buildLineChart now defined
        ],
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 240.h,
              width: 240.w,
              child: PieChart(
                PieChartData(
                  sections: _getPieSections(),
                  centerSpaceRadius: 80,
                  sectionsSpace: 0,
                  startDegreeOffset: 270,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  "\$${isExpenseSelected ? totalExpense : totalIncome}",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  List<PieChartSectionData> _getPieSections() {
    List<Map<String, dynamic>> data =
        isExpenseSelected ? _expenseBreakdown : _incomeBreakdown;

    if (data.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.withOpacity(0.2),
          radius: 30,
          showTitle: false,
        ),
      ];
    }

    final totalAmount = data.fold<double>(
      0,
      (sum, item) => sum + (item['total_amount'] as int).toDouble(),
    );

    final colorMap = {
      'wallet': Colors.orange,
      'bank': Colors.purple,
      'cash': Colors.red,
      'creditCard': Colors.blue,
    };

    return data.map((item) {
      final sourceType = item['source'] as String;
      final amount = (item['total_amount'] as int).toDouble();
      final percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0;

      return PieChartSectionData(
        value: amount,
        color: colorMap[sourceType] ?? Colors.grey,
        radius: 30,
        showTitle: false,
      );
    }).toList();
  }

  // New method to build line chart from real data
  Widget _buildLineChart() {
    // Simulated line chart data (replace with actual database values)
    List<FlSpot> spots = [];
    double maxY = 0;

    if (isExpenseSelected && _expenseBreakdown.isNotEmpty) {
      // Example data generation
      for (int i = 0; i < 6; i++) {
        double value = totalExpense * (0.5 + 0.5 * (i / 5.0)) / 6;
        spots.add(FlSpot(i.toDouble(), value));
        if (value > maxY) maxY = value;
      }
    } else if (!isExpenseSelected && _incomeBreakdown.isNotEmpty) {
      // Similar approach for income
      for (int i = 0; i < 6; i++) {
        double value = totalIncome * (0.5 + 0.5 * (i / 5.0)) / 6;
        spots.add(FlSpot(i.toDouble(), value));
        if (value > maxY) maxY = value;
      }
    } else {
      // Fallback data if no breakdown is available
      spots = [
        const FlSpot(0, 0),
        const FlSpot(1, 0),
        const FlSpot(2, 0),
        const FlSpot(3, 0),
        const FlSpot(4, 0),
        const FlSpot(5, 0),
      ];
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY:
            maxY > 0
                ? maxY * 1.2
                : 10, // Ensure enough headroom above the max value
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.purple,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton("Expense", isExpenseSelected, () {
          setState(() {
            isExpenseSelected = true;
          });
        }),
        SizedBox(width: 10.w),
        _buildToggleButton("Income", !isExpenseSelected, () {
          setState(() {
            isExpenseSelected = false;
          });
        }),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple : Colors.grey[200],
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: selectedTransactionType,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.purple),
          items:
              ["Transaction", "Category"]
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              selectedTransactionType = value!;
            });
          },
          underline: Container(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: () {
            // Implement filter logic
          },
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (selectedTransactionType == "Category") {
      return _buildCategoryList();
    } else {
      return _buildTransactionCardList();
    }
  }

  Widget _buildCategoryList() {
    List<Map<String, dynamic>> data =
        isExpenseSelected ? _expenseBreakdown : _incomeBreakdown;

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Text(
            "No ${isExpenseSelected ? 'expense' : 'income'} data available",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ),
      );
    }

    final totalAmount = data.fold<double>(
      0,
      (sum, item) => sum + (item['total_amount'] as int).toDouble(),
    );
    final colorMap = {
      'wallet': Colors.orange,
      'bank': Colors.purple,
      'cash': Colors.red,
      'creditCard': Colors.blue,
    };

    final displayNames = {
      'wallet': 'Wallet',
      'bank': 'Bank',
      'cash': 'Cash',
      'creditCard': 'Credit Card',
    };

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final sourceType = item['source'] as String;
        final amount = item['total_amount'] as int;
        final percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: colorMap[sourceType] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        displayNames[sourceType] ?? sourceType,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${isExpenseSelected ? '-' : '+'} \$${amount}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isExpenseSelected ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Stack(
                children: [
                  Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage / 100,
                    child: Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: colorMap[sourceType] ?? Colors.grey,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionCardList() {
    List<Map<String, dynamic>> data =
        isExpenseSelected ? _expenseBreakdown : _incomeBreakdown;

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Text(
            "No ${isExpenseSelected ? 'expense' : 'income'} transactions available",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ),
      );
    }

    final colorMap = {
      'wallet': Colors.orange,
      'bank': Colors.purple,
      'cash': Colors.red,
      'creditCard': Colors.blue,
    };
    final displayNames = {
      'wallet': 'Wallet',
      'bank': 'Bank',
      'cash': 'Cash',
      'creditCard': 'Credit Card',
    };

    List<Map<String, dynamic>> transactions =
        data.map((item) {
          final sourceType = item['source'] as String;
          final amount = item['total_amount'] as int;

          return {
            "category": displayNames[sourceType] ?? sourceType,
            "amount": isExpenseSelected ? -amount : amount,
            "color": colorMap[sourceType] ?? Colors.grey,
            "description":
                "${isExpenseSelected ? 'Expense from' : 'Income to'} ${displayNames[sourceType] ?? sourceType}",
            "time": "Today",
          };
        }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(transactions[index]);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: transaction["color"].withOpacity(0.2),
            child: Icon(Icons.category, color: transaction["color"]),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction["category"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transaction["description"],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${transaction["amount"] > 0 ? "+ " : "- "}\$${transaction["amount"].abs().toString()}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: transaction["amount"] > 0 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                transaction["time"],
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
