import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';

class CreateBudgetScreen extends StatefulWidget {
  const CreateBudgetScreen({super.key});

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  String? _selectedCategory;
  bool _receiveAlert = false;
  int amount = 0;
  bool _isLoading = false;

  TextEditingController amountController = TextEditingController();
  TextEditingController budgetNameController = TextEditingController();

  late StreamSubscription<BudgetState> budgetStreamSubscription;

  final List<String> _categories = [
    "Food",
    "Shopping",
    "Transport",
    "Subscription",
  ];

  Future<void> incomeBlocChangeHandler(BudgetState state) async {
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
                            Navigator.pop(context);
                            Navigator.pop(context);
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
  void initState() {
    // TODO: implement initState
    budgetStreamSubscription = BlocProvider.of<BudgetBloc>(
      context,
    ).stream.listen(incomeBlocChangeHandler);
    incomeBlocChangeHandler(BlocProvider.of<BudgetBloc>(context).state);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLoading ? Colors.white : Colors.purple,
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "How much do you want to spend?",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "\$",
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.start,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                amount = value.isEmpty ? 0 : int.parse(value);
                              });
                            },
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText: "0",
                              hintStyle: TextStyle(color: Colors.white70),
                              constraints: BoxConstraints(minWidth: 10.w),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildBottomSheet()),
                ],
              ),
    );
  }

  /// 🔹 AppBar with Back Button
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.purple,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        "Create Budget",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 🔹 Bottom Sheet with Category and Alert Toggle
  Widget _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Budget Name", budgetNameController),
          const SizedBox(height: 15),
          _buildAlertToggle(),
          const Spacer(),
          _buildContinueButton(),
        ],
      ),
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

  /// 🔹 Receive Alert Toggle
  Widget _buildAlertToggle() {
    return SwitchListTile(
      title: const Text("Receive Alert"),
      subtitle: const Text("Receive alert when it reaches some point."),
      value: _receiveAlert,
      activeColor: Colors.purple,
      onChanged: (value) {
        setState(() {
          _receiveAlert = value;
        });
      },
    );
  }

  /// 🔹 Continue Button
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Implement continue logic
          if (amountController.text.isNotEmpty &&
              budgetNameController.text.isNotEmpty) {
            BlocProvider.of<BudgetBloc>(context).add(
              BudgetEvent.createBudget(
                amount: int.parse(amountController.text),
                budgetName: budgetNameController.text,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please Enter all the details'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: const Text(
          "Continue",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
