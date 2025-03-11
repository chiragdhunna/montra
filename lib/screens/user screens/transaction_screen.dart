import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedFilter = "Month";

  final List<Map<String, dynamic>> _transactions = [
    {
      "category": "Shopping",
      "icon": Icons.shopping_bag,
      "color": Colors.orange,
      "description": "Buy some grocery",
      "amount": -120,
      "time": "10:00 AM",
      "date": "Today",
    },
    {
      "category": "Subscription",
      "icon": Icons.subscriptions,
      "color": Colors.purple,
      "description": "Disney+ Annual..",
      "amount": -80,
      "time": "03:30 PM",
      "date": "Today",
    },
    {
      "category": "Food",
      "icon": Icons.restaurant,
      "color": Colors.red,
      "description": "Buy a ramen",
      "amount": -32,
      "time": "07:30 PM",
      "date": "Today",
    },
    {
      "category": "Salary",
      "icon": Icons.attach_money,
      "color": Colors.green,
      "description": "Salary for July",
      "amount": 5000,
      "time": "04:30 PM",
      "date": "Yesterday",
    },
    {
      "category": "Transportation",
      "icon": Icons.directions_car,
      "color": Colors.blue,
      "description": "Charging Tesla",
      "amount": -18,
      "time": "08:30 PM",
      "date": "Yesterday",
    },
  ];

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String selectedTransactionType = "Expense";
            String selectedSortType = "Newest";
            int selectedCategoryCount = 0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterHeader(setModalState),
                    _buildFilterBySection(
                      setModalState,
                      selectedTransactionType,
                    ),
                    _buildSortBySection(setModalState, selectedSortType),
                    _buildCategorySection(setModalState, selectedCategoryCount),
                    SizedBox(height: 15.h),
                    _buildApplyButton(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterHeader(Function setModalState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Filter Transaction",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            setModalState(() {});
          },
          child: const Text("Reset", style: TextStyle(color: Colors.purple)),
        ),
      ],
    );
  }

  Widget _buildFilterBySection(Function setModalState, String selectedType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Filter By",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              ["Income", "Expense", "Transfer"].map((type) {
                bool isSelected = selectedType == type;
                return _filterOption(type, isSelected, () {
                  setModalState(() {
                    selectedType = type;
                  });
                });
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortBySection(Function setModalState, String selectedSort) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        const Text(
          "Sort By",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          children:
              ["Highest", "Lowest", "Newest", "Oldest"].map((sort) {
                bool isSelected = selectedSort == sort;
                return _filterOption(sort, isSelected, () {
                  setModalState(() {
                    selectedSort = sort;
                  });
                });
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection(Function setModalState, int selectedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        const Text(
          "Category",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: () {
            // Implement category selection logic
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Choose Category",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  "$selectedCount Selected",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterOption(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.purple.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.purple : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: const Text(
          "Apply",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(),
            SizedBox(height: 10.h),
            _buildFinancialReportButton(),
            SizedBox(height: 10.h),
            Expanded(child: _buildTransactionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: _selectedFilter,
          items:
              ["Week", "Month", "Year"]
                  .map(
                    (filter) =>
                        DropdownMenuItem(value: filter, child: Text(filter)),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              _selectedFilter = value!;
            });
          },
          underline: Container(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in _transactions) {
      if (!groupedTransactions.containsKey(transaction["date"])) {
        groupedTransactions[transaction["date"]] = [];
      }
      groupedTransactions[transaction["date"]]!.add(transaction);
    }

    return ListView(
      children:
          groupedTransactions.keys.map((date) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Column(
                  children:
                      groupedTransactions[date]!
                          .map(
                            (transaction) => _buildTransactionItem(transaction),
                          )
                          .toList(),
                ),
                SizedBox(height: 15.h),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: transaction["color"].withOpacity(0.2),
            child: Icon(transaction["icon"], color: transaction["color"]),
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
                (transaction["amount"] > 0 ? "+ " : "- ") +
                    transaction["amount"].abs().toString(),
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

  Widget _buildFinancialReportButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "See your financial report",
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
        ],
      ),
    );
  }
}
