import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/api/bank/models/bank_model.dart';
import 'package:montra/logic/api/bank/models/banks_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_model.dart';
import 'package:montra/logic/api/wallet/models/wallets_model.dart';
import 'package:montra/logic/blocs/account_bloc/account_bloc.dart';
import 'package:montra/screens/user_screens/profile_section/account%20screens/account_management_screen.dart';
import 'package:montra/screens/user_screens/profile_section/account%20screens/detail_account_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  WalletsModel wallets = WalletsModel(wallets: []);
  BanksModel banks = BanksModel(banks: []);
  bool isLoading = false;
  int totalBalance = 0;

  late StreamSubscription<AccountState> accountStreamSubscription;

  final List<Map<String, String>> _banks = [
    {"name": "Chase", "logo": "assets/chase_logo.png"},
    {"name": "PayPal", "logo": "assets/paypal_logo.png"},
    {"name": "Citi", "logo": "assets/citi_logo.png"},
    {"name": "Bank of America", "logo": "assets/bofa_logo.png"},
    {"name": "Jago", "logo": "assets/jago_logo.png"},
    {"name": "Mandiri", "logo": "assets/mandiri_logo.png"},
    {"name": "BCA", "logo": "assets/bca_logo.png"},
  ];

  Future<void> accountOnChangeSubscription(AccountState state) async {
    state.maybeWhen(
      orElse: () {},
      inProgress: () {
        setState(() {
          isLoading = true;
        });
      },
      getAccountDetailsSuccess: (balance, fetchedWallets, fetchedBanks) {
        setState(() {
          isLoading = false;
          totalBalance = balance;
          wallets = fetchedWallets;
          banks = fetchedBanks;
        });
      },
    );
  }

  Widget _buildBankLogo(BankModel bank) {
    final bankData = _banks.firstWhere(
      (b) => b['name']!.toLowerCase() == bank.name.toLowerCase(),
      orElse: () => {"logo": ""},
    );

    final logoPath = bankData['logo'];

    if (logoPath == null || logoPath.isEmpty) {
      return const Icon(Icons.account_balance, color: Colors.indigo, size: 20);
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Image.asset(logoPath, fit: BoxFit.contain),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    accountStreamSubscription = BlocProvider.of<AccountBloc>(
      context,
    ).stream.listen(accountOnChangeSubscription);
    BlocProvider.of<AccountBloc>(context).add(AccountEvent.getAccountDetails());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Combine wallets and banks safely (nullable lists)
    final List<dynamic> accounts = [
      ...(wallets.wallets ?? []),
      ...(banks.banks ?? []),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Background blobs
                  Positioned(
                    top: -20,
                    right: -20,
                    child: _blob(100, Colors.purple.shade200.withOpacity(0.5)),
                  ),
                  Positioned(
                    top: 50,
                    right: 80,
                    child: _blob(40, Colors.purple.shade200.withOpacity(0.3)),
                  ),
                  Positioned(
                    top: 20,
                    left: 80,
                    child: _blob(30, Colors.purple.shade200.withOpacity(0.4)),
                  ),

                  // Main content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Account Balance',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$$totalBalance',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Account list or empty message
                          Expanded(
                            child:
                                accounts.isEmpty
                                    ? const Center(
                                      child: Text(
                                        'No accounts found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                    : ListView.separated(
                                      itemCount: accounts.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final account = accounts[index];

                                        // Safely extract name and amount
                                        final String name;
                                        final int amount;

                                        if (account is WalletModel) {
                                          name = account.name;
                                          amount = account.amount;
                                        } else if (account is BankModel) {
                                          name = account.name;
                                          amount = account.amount;
                                        } else {
                                          name = 'Unknown';
                                          amount = 0;
                                        }

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => DetailAccountScreen(
                                                      accountName: name,
                                                      amount: amount,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child:
                                                      account is WalletModel
                                                          ? Icon(
                                                            Icons
                                                                .account_balance_wallet,
                                                            color:
                                                                Colors.purple,
                                                            size: 20,
                                                          )
                                                          : _buildBankLogo(
                                                            account,
                                                          ),
                                                ),

                                                const SizedBox(width: 16),
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '\$$amount',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),

                          // Add wallet button
                          Container(
                            width: double.infinity,
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const AccountManagementScreen(
                                          isAccountEdit: false,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade500,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add new wallet',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  // Background blob helper widget
  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
