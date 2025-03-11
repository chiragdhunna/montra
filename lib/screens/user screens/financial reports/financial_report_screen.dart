import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  bool isExpenseSelected = true;
  bool isGraphSelected = true;
  String selectedTransactionType = "Transaction";
  String selectedCategory = "Category";

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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSection(),
              SizedBox(height: 10.h),
              _buildFinancialReportHeader(),
              SizedBox(height: 10.h),
              _buildGraph(),
              SizedBox(height: 20.h),
              _buildToggleButtons(),
              SizedBox(height: 10.h),
              _buildTransactionFilters(),
              SizedBox(height: 10.h),
              _buildTransactionList(), // This will be scrollable now!
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
          value: "Month",
          items:
              ["Week", "Month", "Year"]
                  .map(
                    (filter) =>
                        DropdownMenuItem(value: filter, child: Text(filter)),
                  )
                  .toList(),
          onChanged: (value) {},
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

  Widget _buildFinancialReportHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "\$${isExpenseSelected ? 332 : 6000}",
          style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGraph() {
    return SizedBox(
      height: 180.h,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2),
                FlSpot(3, 4),
                FlSpot(4, 3),
                FlSpot(5, 5),
              ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
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
    List<Map<String, dynamic>> transactions =
        isExpenseSelected
            ? [
              {
                "category": "Shopping",
                "amount": -120,
                "color": Colors.orange,
                "description": "Buy some grocery",
                "time": "10:00 AM",
              },
              {
                "category": "Subscription",
                "amount": -80,
                "color": Colors.purple,
                "description": "Disney+ Annual..",
                "time": "03:30 PM",
              },
              {
                "category": "Food",
                "amount": -32,
                "color": Colors.red,
                "description": "Buy a ramen",
                "time": "07:30 PM",
              },
            ]
            : [
              {
                "category": "Salary",
                "amount": 5000,
                "color": Colors.green,
                "description": "Salary for July",
                "time": "04:30 PM",
              },
              {
                "category": "Passive Income",
                "amount": 1000,
                "color": Colors.black,
                "description": "UI8 Sales",
                "time": "08:30 PM",
              },
            ];

    return ListView.builder(
      shrinkWrap: true, // Allows it to be inside SingleChildScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Disables nested scrolling
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
}
