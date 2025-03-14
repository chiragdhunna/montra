import 'package:flutter/material.dart';
import 'package:montra/screens/user%20screens/profile%20section/account%20screens/account_management_screen.dart';

class DetailAccountScreen extends StatefulWidget {
  const DetailAccountScreen({super.key});

  @override
  State<DetailAccountScreen> createState() => _DetailAccountScreenState();
}

class _DetailAccountScreenState extends State<DetailAccountScreen> {
  @override
  Widget build(BuildContext context) {
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
                      (builder) => AccountManagementScreen(isAccountEdit: true),
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                        child: Image.asset(
                          'assets/paypal_logo.png',
                          width: 30,
                          height: 30,
                          color: const Color(0xFF0F2A7A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Paypal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$2400',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Transactions section - Today
              _buildSectionHeader('Today'),
              _buildTransactionItem(
                icon: Icons.shopping_bag,
                iconBackgroundColor: const Color(0xFFFEF1D6),
                iconColor: Colors.orange,
                title: 'Shopping',
                subtitle: 'Buy some grocery',
                amount: '-\$120',
                time: '10:00 AM',
              ),
              _buildTransactionItem(
                icon: Icons.description,
                iconBackgroundColor: const Color(0xFFE6E4FA),
                iconColor: Colors.indigo,
                title: 'Subscription',
                subtitle: 'Disney+ Annual...',
                amount: '-\$80',
                time: '03:30 PM',
              ),
              _buildTransactionItem(
                icon: Icons.restaurant,
                iconBackgroundColor: const Color(0xFFFFE9E7),
                iconColor: Colors.red,
                title: 'Food',
                subtitle: 'Buy a ramen',
                amount: '-\$32',
                time: '07:30 PM',
              ),

              // Transactions section - Yesterday
              _buildSectionHeader('Yesterday'),
              _buildTransactionItem(
                icon: Icons.directions_car,
                iconBackgroundColor: const Color(0xFFE2F1FF),
                iconColor: Colors.blue,
                title: 'Transportation',
                subtitle: 'Charging Tesla',
                amount: '-\$18',
                time: '02:30 PM',
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
