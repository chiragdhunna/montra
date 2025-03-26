import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/api/bank/models/bank_model.dart';
import 'package:montra/logic/api/expense/models/expense_model.dart';
import 'package:montra/logic/api/income/models/income_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_model.dart';
import 'package:montra/logic/blocs/account_bloc/account_bloc.dart';
import 'package:montra/screens/user_screens/profile_section/account%20screens/account_management_screen.dart';
import 'package:montra/constants/models/transaction_data_model.dart';
import 'package:montra/screens/user_screens/profile_section/account%20screens/edit_account_screen.dart';

class DetailAccountScreen extends StatefulWidget {
  WalletModel? wallet;
  BankModel? bank;

  DetailAccountScreen({super.key, this.wallet, this.bank});

  @override
  State<DetailAccountScreen> createState() => _DetailAccountScreenState();
}

class _DetailAccountScreenState extends State<DetailAccountScreen> {
  bool isLoading = false;
  List<IncomeModel> _incomes = [];
  List<ExpenseModel> _expenses = [];

  final List<Map<String, String>> _banks = [
    {"name": "Chase", "logo": "assets/chase_logo.png"},
    {"name": "PayPal", "logo": "assets/paypal_logo.png"},
    {"name": "Citi", "logo": "assets/citi_logo.png"},
    {"name": "Bank of America", "logo": "assets/bofa_logo.png"},
    {"name": "Jago", "logo": "assets/jago_logo.png"},
    {"name": "Mandiri", "logo": "assets/mandiri_logo.png"},
    {"name": "BCA", "logo": "assets/bca_logo.png"},
  ];

  String? accountName;
  int? accountAmount;

  late StreamSubscription<AccountState> accountSubscription;

  Future<void> accountOnChange(AccountState state) async {
    state.maybeWhen(
      orElse: () {},
      updateBankBalanceSuccess: () {
        setState(() {
          isLoading = false;
          BlocProvider.of<AccountBloc>(context).add(
            AccountEvent.getAccountSourceDetails(
              wallet: widget.wallet,
              bank: widget.bank,
            ),
          );
        });
      },
      updateWalletSuccess: () {
        setState(() {
          isLoading = false;
          BlocProvider.of<AccountBloc>(context).add(
            AccountEvent.getAccountSourceDetails(
              wallet: widget.wallet,
              bank: widget.bank,
            ),
          );
        });
      },
      getAccountSourceDetailsSuccess: (transactions) {
        setState(() {
          _incomes = transactions?.incomes ?? [];
          _expenses = transactions?.expenses ?? [];

          isLoading = false;
        });
      },
      getAccountBalanceSuccess: (balance) {
        setState(() {
          isLoading = false;
        });
      },
      getAccountDetailsSuccess: (balance, wallets, banks) {
        setState(() {
          isLoading = false;
        });
      },
      createAccountSuccess: () {
        setState(() {
          isLoading = false;
        });
      },
      inProgress: () {
        setState(() {
          isLoading = true;
        });
      },
      initial: () {
        setState(() {
          isLoading = false;
        });
      },
      failure: (error) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error : $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
      },
    );
  }

  Map<String, List<TransactionItemData>> _groupTransactions() {
    final Map<String, List<TransactionItemData>> grouped = {};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    List<TransactionItemData> all = [
      ..._expenses.map(
        (e) => TransactionItemData(
          isIncome: false,
          amount: e.amount,
          description: e.description,
          createdAt: e.createdAt,
        ),
      ),
      ..._incomes.map(
        (i) => TransactionItemData(
          isIncome: true,
          amount: i.amount,
          description: i.description ?? "No description",
          createdAt: i.createdAt,
        ),
      ),
    ];

    for (var item in all) {
      final createdDate = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      String key;

      if (createdDate == today) {
        key = 'Today';
      } else if (createdDate == yesterday) {
        key = 'Yesterday';
      } else {
        key =
            "${createdDate.day.toString().padLeft(2, '0')} "
            "${_monthName(createdDate.month)} ${createdDate.year}";
      }

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
      grouped[key]!.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      ); // <-- descending sort
    }

    return grouped;
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  @override
  void initState() {
    // TODO: implement initState
    accountName =
        widget.wallet != null ? widget.wallet!.name : widget.bank!.name;
    accountAmount =
        widget.wallet != null ? widget.wallet!.amount : widget.bank!.amount;

    accountSubscription = BlocProvider.of<AccountBloc>(
      context,
    ).stream.listen(accountOnChange);
    accountOnChange(BlocProvider.of<AccountBloc>(context).state);
    BlocProvider.of<AccountBloc>(context).add(
      AccountEvent.getAccountSourceDetails(
        wallet: widget.wallet,
        bank: widget.bank,
      ),
    );
    super.initState();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? "PM" : "AM";
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the account name matches a bank
    final bankData = _banks.firstWhere(
      (b) => b['name']!.toLowerCase() == accountName!.toLowerCase(),
      orElse: () => {"logo": ""},
    );

    final isBank = bankData['logo']!.isNotEmpty;
    final String logoPath = bankData['logo'] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail account',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (builder) => EditAccountScreen(
                        wallet: widget.wallet,
                        bank: widget.bank,
                      ),
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // PayPal account header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6EFFC),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child:
                                    isBank
                                        ? Image.asset(
                                          logoPath,
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.contain,
                                        )
                                        : Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.purple,
                                          size: 30,
                                        ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              accountName!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${accountAmount}', // You can make this dynamic if needed
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      if (_expenses.isNotEmpty || _incomes.isNotEmpty) ...[
                        ..._groupTransactions().entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(entry.key),
                              ...entry.value.map((item) {
                                return _buildTransactionItem(
                                  icon:
                                      item.isIncome
                                          ? Icons.attach_money
                                          : Icons.money_off,
                                  iconBackgroundColor:
                                      item.isIncome
                                          ? const Color(0xFFE6F4EA)
                                          : const Color(0xFFFFE9E7),
                                  iconColor:
                                      item.isIncome ? Colors.green : Colors.red,
                                  title: item.isIncome ? "Income" : "Expense",
                                  subtitle: item.description,
                                  amount:
                                      "${item.isIncome ? '+' : '-'}\$${item.amount}",
                                  time: _formatTime(item.createdAt),
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ] else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(
                            child: Text("No transactions available"),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: amount.startsWith('-') ? Colors.red : Colors.green,
                ),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
