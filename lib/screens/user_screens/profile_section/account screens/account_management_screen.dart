import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/blocs/account_bloc/account_bloc.dart';

class AccountManagementScreen extends StatefulWidget with SU {
  const AccountManagementScreen({super.key, required this.isAccountEdit});

  final bool isAccountEdit;

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String? _selectedAccountType = "Wallet";
  String? _selectedBankName; // Tracks which bank is selected

  late StreamSubscription<AccountState> accountStreamSubscription;

  int amount = 0;
  final TextEditingController _walletController = TextEditingController(
    text: "Wallet",
  );
  final TextEditingController _paypalController = TextEditingController(
    text: "Paypal",
  );

  bool isLoading = false;

  TextEditingController amountEditingController = TextEditingController();

  final List<String> _accountTypes = ["Bank", "Wallet"];

  final Set<String> _validBankNames = {
    "Chase",
    "PayPal",
    "Citi",
    "Bank of America",
    "Jago",
    "Mandiri",
    "BCA",
  };

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

  Future<void> accountOnChangeSubscription(AccountState state) async {
    state.maybeWhen(
      orElse: () {},
      inProgress: () {
        setState(() {
          isLoading = true;
        });
      },
      failure: (error) {
        if (error == "Bank already exists") {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bank with same name already exists'),
                backgroundColor: Colors.red,
              ),
            );
          });
        } else {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Something went wrong'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      },
      getAccountDetailsSuccess: (balance, fetchedWallets, fetchedBanks) {
        setState(() {
          isLoading = false;
        });
      },
      createAccountSuccess: () {
        setState(() {
          isLoading = false;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.purple,
                          size: 40.r,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Wallet successfully added",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    amountEditingController = TextEditingController(text: 0.toString());
    accountStreamSubscription = BlocProvider.of<AccountBloc>(
      context,
    ).stream.listen(accountOnChangeSubscription);
    accountOnChangeSubscription(BlocProvider.of<AccountBloc>(context).state);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isLoading ? Colors.white : const Color(0xFF8A56FF),
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
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      "Balance",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "\$",
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            controller: amountEditingController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.start,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                amount = value.isEmpty ? 0 : int.parse(value);
                              });
                            },
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText: "0",
                              hintStyle: TextStyle(color: Colors.white70),
                              constraints: BoxConstraints(minWidth: 10.w),
                            ),
                          ),
                        ),
                      ],
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
                            if (_selectedAccountType == "Wallet")
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                                  final enteredAmount =
                                      int.tryParse(
                                        amountEditingController.text,
                                      ) ??
                                      0;

                                  if (_selectedAccountType == "Bank") {
                                    // Check for valid bank name
                                    if (_selectedBankName == null ||
                                        !_validBankNames.contains(
                                          _selectedBankName,
                                        )) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please select a valid bank before continuing.",
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    // Call BLoC for bank account
                                    BlocProvider.of<AccountBloc>(context).add(
                                      AccountEvent.createAccount(
                                        isWallet: false,
                                        name: _selectedBankName!,
                                        amount: enteredAmount,
                                      ),
                                    );
                                  } else {
                                    if (amountEditingController
                                            .text
                                            .isNotEmpty &&
                                        _walletController.text.isNotEmpty) {
                                      BlocProvider.of<AccountBloc>(context).add(
                                        AccountEvent.createAccount(
                                          isWallet: true,
                                          name: _walletController.text,
                                          amount: enteredAmount,
                                        ),
                                      );
                                    } else {
                                      // TODO: handle wallet case when implemented
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please fill all the details",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
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
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBankName = bank["name"];
              _paypalController.text = bank["name"]!;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _selectedBankName == bank["name"]
                        ? Colors.purple
                        : Colors.grey.shade300,
                width: _selectedBankName == bank["name"] ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Center(
              child: Text(
                "See Other",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight:
                      _selectedBankName == bank["name"]
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      } else {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBankName = bank["name"];
              _paypalController.text = bank["name"]!;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _selectedBankName == bank["name"]
                        ? Colors.purple
                        : Colors.grey.shade300,
                width: _selectedBankName == bank["name"] ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Center(
              child:
                  bank["logo"]!.isNotEmpty
                      ? Image.asset(
                        bank["logo"]!,
                        height: 24,
                        fit: BoxFit.contain,
                      )
                      : Text(
                        bank["name"]!.substring(0, 1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
            ),
          ),
        );
      }
    }).toList();
  }
}
