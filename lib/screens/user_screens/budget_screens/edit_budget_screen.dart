import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';
import 'package:montra/screens/user_screens/budget_screen.dart';

class EditBudgetScreen extends StatefulWidget with SU {
  final String? budgetId;
  final String? category;
  final double? current;
  final String? name;
  final double? totalBudget;
  final Color? color;

  const EditBudgetScreen({
    Key? key,
    required this.budgetId,
    required this.category,
    required this.current,
    required this.name,
    required this.totalBudget,
    required this.color,
  }) : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  bool _receiveAlert = true;
  late double _sliderValue;
  late TextEditingController _totalBudgetController;
  late TextEditingController _budgetNameController;
  late TextEditingController _budgetAmountController;
  bool _isLoading = false;

  late StreamSubscription<BudgetState> bugetStreamListener;

  final List<String> _categories = [
    'Shopping',
    'Groceries',
    'Transportation',
    'Entertainment',
    'Dining Out',
    'Utilities',
    'Rent',
    'Other',
  ];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize values from widget parameters or defaults
    _selectedCategory = widget.category ?? 'Shopping';
    _totalBudgetController = TextEditingController(
      text: widget.totalBudget?.toStringAsFixed(2) ?? '0.00',
    );
    _budgetAmountController = TextEditingController(
      text: widget.current?.toStringAsFixed(2) ?? '0.00',
    );
    _budgetNameController = TextEditingController(text: widget.name);

    // Calculate slider value based on current spending
    _sliderValue =
        widget.current != null && widget.totalBudget != null
            ? (widget.current! / widget.totalBudget! * 100).clamp(0.0, 100.0)
            : 80.0;
    bugetStreamListener = BlocProvider.of<BudgetBloc>(
      context,
    ).stream.listen(budgetBlocChangeHandler);
    budgetBlocChangeHandler(BlocProvider.of<BudgetBloc>(context).state);
  }

  @override
  void dispose() {
    _totalBudgetController.dispose();
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

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,

        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLoading ? Colors.white : Colors.purple,
      appBar: AppBar(
        backgroundColor: _isLoading ? Colors.white : Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Budget', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Column(
                          children: [
                            // Top Purple Section
                            Container(
                              width: double.infinity,
                              color: Colors.purple,
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'How much did you spend?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildMoneyField(_budgetAmountController),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'How much do you want to spend?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildMoneyField(_totalBudgetController),
                                ],
                              ),
                            ),

                            // White Scrollable Section
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(
                                    "Budget Name",
                                    _budgetNameController,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Receive Alert'),
                                      Switch(
                                        value: _receiveAlert,
                                        onChanged: (value) {
                                          setState(() => _receiveAlert = value);
                                        },
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'Receive alert when it reaches some point.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          value: _sliderValue,
                                          min: 0,
                                          max: 100,
                                          divisions: 100,
                                          onChanged: (value) {
                                            setState(
                                              () => _sliderValue = value,
                                            );
                                          },
                                          activeColor: Colors.purple,
                                          inactiveColor: Colors.grey[300],
                                        ),
                                      ),
                                      Text('${_sliderValue.toInt()}%'),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_budgetAmountController
                                              .text
                                              .isNotEmpty &&
                                          _budgetNameController
                                              .text
                                              .isNotEmpty &&
                                          _totalBudgetController
                                              .text
                                              .isNotEmpty) {
                                        int totalBudget =
                                            double.parse(
                                              _totalBudgetController.text,
                                            ).toInt();
                                        int current =
                                            double.parse(
                                              _budgetAmountController.text,
                                            ).toInt();

                                        BlocProvider.of<BudgetBloc>(
                                          context,
                                        ).add(
                                          BudgetEvent.updateBudget(
                                            totalBudget: totalBudget,
                                            budgetName:
                                                _budgetNameController.text,
                                            budgetId: widget.budgetId!,
                                            current: current,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Something went wrong',
                                              selectionColor: Colors.red,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Update Budget',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildMoneyField(TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '\$',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
