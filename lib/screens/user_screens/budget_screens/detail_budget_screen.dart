import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';
import 'package:montra/screens/user_screens/budget_screen.dart';
import 'package:montra/screens/user_screens/budget_screens/edit_budget_screen.dart';

class DetailBudgetScreen extends StatefulWidget with SU {
  final String budgetId;
  final String category;
  final double current;
  final String name;
  final double totalBudget;
  final double remaining;
  final Color color;

  const DetailBudgetScreen({
    Key? key,
    required this.budgetId,
    required this.category,
    required this.current,
    required this.name,
    required this.totalBudget,
    required this.remaining,
    required this.color,
  }) : super(key: key);

  @override
  State<DetailBudgetScreen> createState() => _DetailBudgetScreenState();
}

class _DetailBudgetScreenState extends State<DetailBudgetScreen> {
  late StreamSubscription<BudgetState> bugetStreamListener;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize values from widget parameters or defaults

    bugetStreamListener = BlocProvider.of<BudgetBloc>(
      context,
    ).stream.listen(budgetBlocChangeHandler);
    budgetBlocChangeHandler(BlocProvider.of<BudgetBloc>(context).state);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> budgetBlocChangeHandler(BudgetState state) async {
    state.maybeWhen(
      orElse: () {},
      inProgress: () {
        setState(() {
          _isLoading = true;
        });
      },
      failure: () {
        setState(() {
          _isLoading = false;
        });
      },
      createBudgetSuccess: () {
        setState(() {
          _isLoading = false;
        });
      },
      deleteBudgetSuccess: () {
        setState(() {
          _isLoading = false;
          Navigator.of(context).pop();
        });
      },
      updateBudgetSuccess: () {
        setState(() {
          _isLoading = false;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.purple,
                          size: 40.r,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Transaction has been successfully added",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => BudgetScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if budget is exceeded
    bool isExceeded = widget.current > widget.totalBudget;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Detail Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag, color: widget.color),
                          const SizedBox(width: 8.0),
                          Text(widget.category),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Text('Remaining', style: TextStyle(fontSize: 18.0)),
                    const SizedBox(height: 8.0),
                    Text(
                      '\$${widget.remaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      height: 4.0,
                      width: double.infinity,
                      color: widget.color,
                    ),
                    const SizedBox(height: 16.0),
                    if (isExceeded)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text(
                          '⚠️ You\'ve exceeded the limit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (builder) => EditBudgetScreen(
                                  budgetId: widget.budgetId,
                                  category: widget.category,
                                  current: widget.current,
                                  name: widget.name,
                                  totalBudget: widget.totalBudget,
                                  color: widget.color,
                                ),
                          ),
                        );
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(builder: (builder) => EditBudgetScreen()),
                        // );
                      },
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Remove this budget?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Are you sure you want to remove this budget?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement budget deletion logic
                      Navigator.pop(context);
                      BlocProvider.of<BudgetBloc>(context).add(
                        BudgetEvent.deleteBudget(budgetId: widget.budgetId),
                      );
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
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
}
