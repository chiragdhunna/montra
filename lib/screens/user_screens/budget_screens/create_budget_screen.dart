import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateBudgetScreen extends StatefulWidget {
  const CreateBudgetScreen({super.key});

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  String? _selectedCategory;
  bool _receiveAlert = false;

  final List<String> _categories = [
    "Food",
    "Shopping",
    "Transport",
    "Subscription",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "How much do you want to spend?",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          const Text(
            "\$0",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
          _buildDropdownField(),
          const SizedBox(height: 15),
          _buildAlertToggle(),
          const Spacer(),
          _buildContinueButton(),
        ],
      ),
    );
  }

  /// 🔹 Category Dropdown
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items:
          _categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Category",
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
