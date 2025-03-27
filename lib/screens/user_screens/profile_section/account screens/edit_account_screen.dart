import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/api/bank/models/bank_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_model.dart';
import 'package:montra/logic/blocs/account_bloc/account_bloc.dart';

class EditAccountScreen extends StatefulWidget with SU {
  WalletModel? wallet;
  BankModel? bank;
  EditAccountScreen({super.key, this.wallet, this.bank});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String? _selectedBankName; // Tracks which bank is selected

  late StreamSubscription<AccountState> accountStreamSubscription;

  int amount = 0;
  TextEditingController _walletController = TextEditingController(
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
      updateWalletSuccess: () {
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
                        "Wallet Updated Successfully",
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
      updateBankBalanceSuccess: () {
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
                        "Bank Amount Updated",
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
    _walletController = TextEditingController(
      text: widget.wallet != null ? widget.wallet!.name : "",
    );
    amountEditingController = TextEditingController(
      text:
          widget.wallet != null
              ? widget.wallet!.amount.toString()
              : widget.bank!.amount.toString(),
    );
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
          "Edit account",
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
                            if (widget.wallet != null)
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
                                  controller: _walletController,
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

                                  // Check for valid bank name
                                  if (widget.wallet != null &&
                                      amountEditingController.text.isNotEmpty &&
                                      _walletController.text.isNotEmpty) {
                                    BlocProvider.of<AccountBloc>(context).add(
                                      AccountEvent.updateWallet(
                                        name: _walletController.text,
                                        amount: int.parse(
                                          amountEditingController.text,
                                        ),
                                        walletId: widget.wallet!.walletNumber,
                                      ),
                                    );
                                  } else if (widget.bank != null &&
                                      amountEditingController.text.isNotEmpty) {
                                    BlocProvider.of<AccountBloc>(context).add(
                                      AccountEvent.updateBankBalance(
                                        amount: enteredAmount,
                                        accountNumber:
                                            widget.bank!.accountNumber,
                                      ),
                                    );
                                  } else {
                                    // TODO: handle wallet case when implemented
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please fill all the details",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
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
}
