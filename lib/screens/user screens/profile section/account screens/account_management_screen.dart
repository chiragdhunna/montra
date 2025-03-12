import 'package:flutter/material.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key, required this.isAccountEdit});

  final bool isAccountEdit;

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String? _selectedAccountType = "Wallet";
  final TextEditingController _walletController = TextEditingController(
    text: "Wallet",
  );
  final TextEditingController _paypalController = TextEditingController(
    text: "Paypal",
  );

  final List<String> _accountTypes = ["Bank", "Wallet"];

  final List<Map<String, String>> _banks = [
    {"name": "Chase", "logo": "assets/chase_logo.png"},
    {"name": "PayPal", "logo": "assets/paypal_logo.png"},
    {"name": "Citi", "logo": "assets/citi_logo.png"},
    {"name": "Bank of America", "logo": "assets/bofa_logo.png"},
    {"name": "Jago", "logo": "assets/jago_logo.png"},
    {"name": "Mandiri", "logo": "assets/mandiri_logo.png"},
    {"name": "BCA", "logo": "assets/bca_logo.png"},
    {"name": "See Other", "logo": ""},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8A56FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8A56FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.isAccountEdit == true ? "Edit account" : "Add new account",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 20),
            child: Text(
              "Balance",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8, bottom: 24),
            child: Text(
              _selectedAccountType == "Bank" ? "\$2400" : "\$400",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                // Wrap with SingleChildScrollView
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet or Bank name text field
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller:
                            _selectedAccountType == "Bank"
                                ? _paypalController
                                : _walletController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Account Type Dropdown (Bank/Wallet)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAccountType,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                          items:
                              _accountTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountType = value;
                            });
                          },
                        ),
                      ),
                    ),

                    // Bank options grid
                    if (_selectedAccountType == "Bank") ...[
                      const SizedBox(height: 20),
                      const Text(
                        "Bank",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _buildBankOptions(),
                      ),
                    ],

                    const SizedBox(height: 20), // Add some spacing
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle continue
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A56FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBankOptions() {
    return _banks.map((bank) {
      if (bank["name"] == "See Other") {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              "See Other",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child:
              bank["logo"]!.isNotEmpty
                  ? Image.asset(bank["logo"]!, height: 24)
                  : Center(
                    child: Text(
                      bank["name"]!.substring(0, 1),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
        );
      }
    }).toList();
  }
}
