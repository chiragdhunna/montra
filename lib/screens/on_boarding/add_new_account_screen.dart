import 'package:flutter/material.dart';
import 'package:montra/screens/on_boarding/set_up_success.dart';

class AddNewAccountScreen extends StatefulWidget {
  const AddNewAccountScreen({super.key});

  @override
  State<AddNewAccountScreen> createState() => _AddNewAccountScreenState();
}

class _AddNewAccountScreenState extends State<AddNewAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedAccountType;
  String? _selectedBank;

  final List<String> _accountTypes = ["Bank", "Wallet", "Credit Card"];
  final List<Map<String, String>> _banks = [
    {"name": "Chase", "logo": "assets/chase_logo.png"},
    {"name": "PayPal", "logo": "assets/paypal_logo.png"},
    {"name": "Citi", "logo": "assets/citi_logo.png"},
    {"name": "Bank of America", "logo": "assets/bofa_logo.png"},
    {"name": "Bank of America", "logo": "assets/jago_logo.png"},
    {"name": "Mandiri", "logo": "assets/mandiri_logo.png"},
    {"name": "BCA", "logo": "assets/bca_logo.png"},
    {"name": "See Other", "logo": ""},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add new account",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Balance",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 5),
          const Text(
            "\$00.0",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedAccountType,
                    items:
                        _accountTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountType = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Account Type",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_selectedAccountType == "Bank") ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Bank",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children:
                          _banks.map((bank) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBank = bank["name"];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _selectedBank == bank["name"]
                                            ? Colors.purple
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    bank["logo"]!.isNotEmpty
                                        ? Image.asset(bank["logo"]!, height: 30)
                                        : const Text(
                                          "See Other",
                                          style: TextStyle(
                                            color: Colors.purple,
                                          ),
                                        ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Handle account addition logic
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (builder) => SetUpSuccess(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
