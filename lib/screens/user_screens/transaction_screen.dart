import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/blocs/transactions_bloc/transactions_bloc.dart';
import 'package:montra/screens/user_screens/financial_reports/financial_report_status_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedFilter = "Month";
  int _appliedFiltersCount = 1; // Default count for the filter badge
  Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
  List<Map<String, dynamic>> recentTransactions = [];
  late StreamSubscription<TransactionsState> _transactionsStreamSubscription;
  bool _isLoading = true;
  String _selectedTransactionType =
      "All"; // For Filter By: All / Income / Expense / Transfer
  String _selectedSortType = "Newest"; // For Sort By
  List<String> _selectedCategories = []; // For category filter

  final List<String> _availableCategories = [
    "Food",
    "Travel",
    "Shopping",
    "Salary",
    "Subscription",
    "Transportation",
    "Entertainment",
    "Health",
    "Bills",
    // Add more as needed
  ];

  void transactionsBlocChangeHandler(TransactionsState state) {
    state.maybeWhen(
      orElse: () {},
      getAllTransactionSuccess: (transactions) {
        if (!mounted) return;
        setState(() {
          // Store the most recent transactions (e.g., the first 3)
          recentTransactions =
              transactions.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
          log.w('Transactions from recentTransactions : $recentTransactions');
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

  final Map<String, String> sourceDisplayNames = {
    "cash": "Cash",
    "bank": "Bank",
    "creditCard": "Credit Card",
    "upi": "UPI",
    "wallet": "Wallet",
    // Add more if needed
  };

  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void initState() {
    super.initState();

    // Fetch all transactions from BLoC
    BlocProvider.of<TransactionsBloc>(
      context,
    ).add(TransactionsEvent.getAllTransactions());

    // Listen to BLoC state changes
    _transactionsStreamSubscription = BlocProvider.of<TransactionsBloc>(
      context,
    ).stream.listen(transactionsBlocChangeHandler);

    // Handle current state immediately (in case data already exists)
    transactionsBlocChangeHandler(
      BlocProvider.of<TransactionsBloc>(context).state,
    );
  }

  @override
  void dispose() {
    _transactionsStreamSubscription.cancel();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String selectedTransactionType = _selectedTransactionType;
            String selectedSortType = _selectedSortType;

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
                    _buildCategorySection(
                      setModalState,
                      _selectedCategories.length,
                    ),
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
                    _selectedSortType = sort;
                  });
                });
              }).toList(),
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
                    _selectedTransactionType = type;
                  });
                });
              }).toList(),
        ),
      ],
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
            setModalState(() {
              setState(() {
                _selectedTransactionType = "All";
                _selectedSortType = "Newest";
                _selectedCategories.clear();
                _appliedFiltersCount = 0;
              });
            });
          },

          child: const Text("Reset", style: TextStyle(color: Colors.purple)),
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
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children:
              _availableCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return GestureDetector(
                  onTap: () {
                    setModalState(() {
                      setState(() {
                        if (isSelected) {
                          _selectedCategories.remove(category);
                        } else {
                          _selectedCategories.add(category);
                        }
                      });
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.purple.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color:
                            isSelected ? Colors.purple : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.purple : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Trigger BLoC filter event
          BlocProvider.of<TransactionsBloc>(context).add(
            TransactionsEvent.filterTransactions(
              type: _selectedTransactionType.toLowerCase(),
              sortBy: _selectedSortType.toLowerCase(),
              categories: _selectedCategories,
            ),
          );

          setState(() {
            _appliedFiltersCount = 1; // or calculate from actual filters
          });

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
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
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
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: _showFilterBottomSheet,
            ),
            if (_appliedFiltersCount > 0)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple,
                  ),
                  child: Text(
                    "$_appliedFiltersCount",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    DateTime now = DateTime.now();

    DateTime startDate;

    if (_selectedFilter == "Week") {
      startDate = now.subtract(const Duration(days: 7));
    } else if (_selectedFilter == "Month") {
      startDate = DateTime(now.year, now.month - 1, now.day);
    } else if (_selectedFilter == "Year") {
      startDate = DateTime(now.year - 1, now.month, now.day);
    } else {
      startDate = DateTime(2000); // fallback
    }

    // Filter based on selected time duration
    List<Map<String, dynamic>> filteredTransactions =
        recentTransactions.where((transaction) {
          final createdAt = DateTime.parse(
            transaction['data'].createdAt.toString(),
          );
          return createdAt.isAfter(startDate) ||
              createdAt.isAtSameMomentAs(startDate);
        }).toList();

    // Group filtered transactions by date
    for (var transaction in filteredTransactions) {
      final createdAt = DateTime.parse(
        transaction['data'].createdAt.toString(),
      );
      String dateKey;

      final difference =
          now
              .difference(
                DateTime(createdAt.year, createdAt.month, createdAt.day),
              )
              .inDays;

      if (difference == 0) {
        dateKey = "Today";
      } else if (difference == 1) {
        dateKey = "Yesterday";
      } else {
        dateKey =
            "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";
      }

      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return ListView(
      children:
          (groupedTransactions.entries.toList()..sort((a, b) {
                if (a.key == "Today") return -1;
                if (b.key == "Today") return 1;
                if (a.key == "Yesterday") return -1;
                if (b.key == "Yesterday") return 1;

                final aParts = a.key.split('/');
                final bParts = b.key.split('/');

                final aDate = DateTime(
                  int.parse(aParts[2]),
                  int.parse(aParts[1]),
                  int.parse(aParts[0]),
                );
                final bDate = DateTime(
                  int.parse(bParts[2]),
                  int.parse(bParts[1]),
                  int.parse(bParts[0]),
                );

                return bDate.compareTo(aDate);
              }))
              .map((entry) {
                final date = entry.key;
                final transactions = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
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
                          transactions
                              .map(
                                (transaction) =>
                                    _buildTransactionItem(transaction),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 15.h),
                  ],
                );
              })
              .toList(),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    String title = "";
    String subtitle = "";
    int amount = 0;
    Color color = Colors.grey;
    IconData icon = Icons.swap_horiz;

    final type = transaction['type'];
    final data = transaction['data'];

    if (type == 'expense') {
      final rawSource = data.source.toString().split('.').last;
      title = sourceDisplayNames[rawSource] ?? _capitalize(rawSource);

      subtitle = data.description ?? "No description";
      amount = -data.amount;
      color = Colors.red;
      icon = Icons.money_off;
    } else if (type == 'income') {
      final rawSource = data.source.toString().split('.').last;
      title = sourceDisplayNames[rawSource] ?? _capitalize(rawSource);

      subtitle = data.description ?? "No description";
      amount = data.amount;
      color = Colors.green;
      icon = Icons.attach_money;
    } else if (type == 'transfer') {
      title = "Transfer";
      subtitle = "From ${data.sender} to ${data.receiver}";
      amount = data.isExpense ? -data.amount : data.amount;
      color = Colors.blue;
      icon = Icons.compare_arrows;
    }

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
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            (amount > 0 ? "+ " : "- ") + amount.abs().toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amount > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialReportButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (builder) => FinancialReportStatusScreen(),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}
