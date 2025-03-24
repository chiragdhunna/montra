import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/api/budget/models/budget_model.dart';
import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';
import 'package:montra/screens/user_screens/budget_screens/create_budget_screen.dart';
import 'package:montra/screens/user_screens/budget_screens/detail_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Sample budget data structure
  Map<String, List<Map<String, dynamic>>> monthlyBudgets = {};

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

  int currentMonthIndex = DateTime.now().month - 1;
  late StreamSubscription<BudgetState> _budgetStreamSubscription;
  bool _isLoading = false;

  void _changeMonth(bool isNext) {
    setState(() {
      if (isNext) {
        currentMonthIndex = (currentMonthIndex + 1) % 12;
        BlocProvider.of<BudgetBloc>(
          context,
        ).add(BudgetEvent.getBudgetByMonth(month: currentMonthIndex + 1));
      } else {
        currentMonthIndex = (currentMonthIndex - 1 + 12) % 12;
        BlocProvider.of<BudgetBloc>(
          context,
        ).add(BudgetEvent.getBudgetByMonth(month: currentMonthIndex + 1));
      }
    });
  }

  double _calculateRemainingBudget(BudgetModel budget) {
    double spent = double.tryParse(budget.current.toString()) ?? 0.0;
    return budget.totalBudget - spent;
  }

  Color _getCategoryColor(String category) {
    final Map<String, Color> categoryColors = {
      'Groceries': Colors.green,
      'Shopping': Colors.orange,
      'Transportation': Colors.blue,
      'Entertainment': Colors.purple,
      'Dining Out': Colors.red,
      'Holiday Shopping': Colors.teal,
      'Gifts': Colors.deepPurple,
    };
    return categoryColors[category] ?? Colors.grey;
  }

  void budgetBlocChangeHandler(BudgetState state) {
    state.maybeWhen(
      orElse: () {},
      getBudgetByMonthSuccess: (budgetsModel) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;

          // Convert List<BudgetModel> into a format suitable for monthlyBudgets
          monthlyBudgets[months[currentMonthIndex]] =
              budgetsModel.budgets.map((budget) {
                return {
                  'category': budget.name,
                  'remaining': _calculateRemainingBudget(budget),
                  'total': budget.totalBudget.toDouble(),
                  'spent': double.parse(budget.current.toString()),
                  'color': _getCategoryColor(budget.name),
                };
              }).toList();
        });
      },

      failure: () {
        log.d('State is failure');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      },
      inProgress: () {
        log.d('State is inProgress');
        if (!mounted) return;
        setState(() {
          _isLoading = true;
        });
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    BlocProvider.of<BudgetBloc>(
      context,
    ).add(BudgetEvent.getBudgetByMonth(month: currentMonthIndex + 1));
    _budgetStreamSubscription = BlocProvider.of<BudgetBloc>(
      context,
    ).stream.listen(budgetBlocChangeHandler);
    budgetBlocChangeHandler(BlocProvider.of<BudgetBloc>(context).state);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _budgetStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = months[currentMonthIndex];
    List<Map<String, dynamic>> currentMonthBudgets =
        monthlyBudgets[currentMonth] ?? [];
    bool hasBudgetData = currentMonthBudgets.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Column(
          children: [
            _buildMonthSection(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child:
                          hasBudgetData
                              ? _buildBudgetDataUI(currentMonthBudgets)
                              : _buildNoBudgetUI(),
                    ),
                    _buildCreateBudgetButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Month Section
  Widget _buildMonthSection() {
    return Container(
      height: 0.2.sh,
      color: Colors.purple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _changeMonth(false),
          ),
          Text(
            months[currentMonthIndex],
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => _changeMonth(true),
          ),
        ],
      ),
    );
  }

  /// 🔹 UI for when there is budget data
  Widget _buildBudgetDataUI(List<Map<String, dynamic>> budgets) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (builder) => DetailBudgetScreen()));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _buildBudgetCard(
                  budgets[index]['category'],
                  budgets[index]['remaining'].toDouble(),
                  budgets[index]['total'].toDouble(),
                  budgets[index]['spent'].toDouble(),
                  budgets[index]['color'],
                ),
                if (index < budgets.length - 1) SizedBox(height: 10.h),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 🔹 Budget Card Widget
  Widget _buildBudgetCard(
    String category,
    double remaining,
    double total,
    double spent,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              "Remaining \$${remaining.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 14.sp),
            ),
            LinearProgressIndicator(
              value: spent / total,
              color: color,
              backgroundColor: color.withOpacity(0.3),
            ),
            Text(
              "\$${spent.toStringAsFixed(0)} of \$${total.toStringAsFixed(0)}",
            ),
            if (spent > total)
              Text(
                "You've exceeded the limit!",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔹 UI for when there is no budget data
  Widget _buildNoBudgetUI() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "You don't have a budget.",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              "Let's make one so you're in control.",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Create Budget Button
  Widget _buildCreateBudgetButton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Implement Budget Creation Logic
            Navigator.of(context).push(
              MaterialPageRoute(builder: (builder) => CreateBudgetScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: EdgeInsets.symmetric(vertical: 15.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: Text(
            "Create a budget",
            style: TextStyle(fontSize: 16.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
