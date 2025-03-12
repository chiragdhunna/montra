import 'package:flutter/material.dart';
import 'package:montra/screens/user%20screens/profile%20section/account%20screens/account_management_screen.dart';
import 'package:montra/screens/user%20screens/profile%20section/account%20screens/detail_account_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final List<Map<String, dynamic>> accounts = [
    {
      'name': 'Wallet',
      'balance': 400,
      'icon': Icons.account_balance_wallet,
      'iconColor': Colors.blue,
      'iconBgColor': Colors.blue.shade100,
    },
    {
      'name': 'Chase',
      'balance': 1000,
      'icon': Icons.crop_square,
      'iconColor': Colors.blue,
      'iconBgColor': Colors.blue.shade100,
    },
    {
      'name': 'Citi',
      'balance': 6000,
      'icon': null, // This will be a custom logo
      'iconColor': null,
      'iconBgColor': null,
    },
    {
      'name': 'Paypal',
      'balance': 2000,
      'icon': Icons.paypal,
      'iconColor': Colors.indigo,
      'iconBgColor': Colors.indigo.shade100,
    },
  ];

  int get totalBalance =>
      accounts.fold(0, (sum, account) => sum + account['balance'] as int);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background purple blobs
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.purple.shade200.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 80,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.shade200.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 80,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.purple.shade200.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
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
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalBalance}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.separated(
                      itemCount: accounts.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => DetailAccountScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                account['name'] == 'Citi'
                                    ? Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'citi',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            account['iconBgColor'] ??
                                            Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        account['icon'] ??
                                            Icons.account_balance,
                                        color:
                                            account['iconColor'] ?? Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                const SizedBox(width: 16),
                                Text(
                                  account['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${account['balance']}',
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
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (builder) => AccountManagementScreen(
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
}
