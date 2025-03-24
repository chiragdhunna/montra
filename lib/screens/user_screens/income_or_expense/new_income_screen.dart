import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:montra/constants/income_source.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';

class NewIncomeScreen extends StatefulWidget {
  const NewIncomeScreen({super.key});

  @override
  State<NewIncomeScreen> createState() => _NewIncomeScreenState();
}

class _NewIncomeScreenState extends State<NewIncomeScreen> {
  String? _selectedCategory;
  String? _selectedSource;
  IncomeSource _selectedIcomeSource = IncomeSource.wallet;
  bool _isRepeat = false;
  bool _isRepeatConfigured = false;
  File? _selectedImage;
  int amount = 0;
  bool _isLoading = false;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late StreamSubscription<IncomeState> incomeStreamSubscription;

  String _repeatFrequency = "Yearly";
  String _repeatMonth = "Dec";
  String _repeatDay = "29";
  String _repeatEndDate = "29 Dec 2025";

  final List<String> _sources = ["Salary", "Freelance", "Investment", "Bonus"];
  final List<String> _wallets = ["Bank", "Cash", "Credit Card", "Wallet"];
  final List<String> _months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  final List<String> _days = List.generate(31, (index) => "${index + 1}");
  final List<String> _frequencies = ["Daily", "Weekly", "Monthly", "Yearly"];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeAttachment() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    incomeStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    incomeStreamSubscription = BlocProvider.of<IncomeBloc>(
      context,
    ).stream.listen(incomeBlocChangeHandler);
    incomeBlocChangeHandler(BlocProvider.of<IncomeBloc>(context).state);
    super.initState();
  }

  Future<void> incomeBlocChangeHandler(IncomeState state) async {
    state.maybeWhen(
      orElse: () {},
      inProgress: () {
        setState(() {
          _isLoading = true;
        });
      },
      failure: () {
        setState(() {
          _isLoading = false;
        });
      },
      createIncomeSuccess: () {
        setState(() {
          _isLoading = false;
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
                        "Transaction has been successfully added",
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

  void _showSuccessDialog() {
    log.w('Amount : ${amountController.text}');
    log.w('Category : ${_selectedCategory}');
    log.w('Description : ${descriptionController.text}');
    log.w('_selectedIncomeSource : ${_selectedIcomeSource}');
    if (amountController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        _selectedImage != null) {
      BlocProvider.of<IncomeBloc>(context).add(
        IncomeEvent.createIncome(
          amount: int.parse(amountController.text),
          source: _selectedIcomeSource,
          description: descriptionController.text,
          attachment: _selectedImage,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill all the fields"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLoading ? Colors.white : Colors.green,
      appBar: AppBar(
        backgroundColor: _isLoading ? Colors.white : Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Income",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    "How much?",
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                  SizedBox(height: 10.h),
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
                            controller: amountController,
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
                  SizedBox(height: 20.h),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: ListView(
                        children: [
                          _buildDropdownField(
                            "Category",
                            _selectedCategory ?? "Category",
                            _sources,
                            (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextField("Description", descriptionController),
                          const SizedBox(height: 15),
                          _buildDropdownField(
                            "Wallet",
                            _selectedSource ?? "Wallet",
                            _wallets,
                            (value) {
                              setState(() {
                                _selectedSource = value;
                                if (_selectedSource == "Wallet") {
                                  _selectedIcomeSource = IncomeSource.wallet;
                                } else if (_selectedSource == "Bank") {
                                  _selectedIcomeSource = IncomeSource.bank;
                                } else if (_selectedSource == "Cash") {
                                  _selectedIcomeSource = IncomeSource.cash;
                                } else {
                                  _selectedIcomeSource =
                                      IncomeSource.creditCard;
                                }
                              });
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildAttachmentSection(),
                          SizedBox(height: 20.h),
                          _buildRepeatTransactionToggle(),
                          SizedBox(height: 20.h),
                          _buildContinueButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    // Only set the value if it's in the options list
    final currentValue = options.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: currentValue,
      hint: Text(label), // Use hint instead of trying to use label as a value
      items:
          options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,

        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showSuccessDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: const Text(
          "Continue",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // Add this to your _buildRepeatTransactionToggle() method
  Widget _buildRepeatTransactionToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text("Repeat transaction, set your own time"),
          value: _isRepeat,
          onChanged: (value) {
            setState(() {
              _isRepeat = value;
              if (value) {
                _showRepeatBottomSheet();
              } else {
                _isRepeatConfigured = false;
              }
            });
          },
          activeColor: Colors.purple,
        ),
        if (_isRepeatConfigured)
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Frequency",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$_repeatFrequency - $_repeatMonth $_repeatDay",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 5),
                const Text(
                  "End After",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  _repeatEndDate,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showRepeatBottomSheet,
                    child: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Add this method to show the repeat transaction bottom sheet
  void _showRepeatBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDropdownField(
                    "Frequency",
                    _repeatFrequency,
                    _frequencies,
                    (value) {
                      setModalState(() {
                        _repeatFrequency = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          "Month",
                          _repeatMonth,
                          _months,
                          (value) {
                            setModalState(() {
                              _repeatMonth = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdownField("Day", _repeatDay, _days, (
                          value,
                        ) {
                          setModalState(() {
                            _repeatDay = value!;
                          });
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDropdownField(
                    "End After",
                    _repeatEndDate,
                    ["29 Dec 2025"],
                    (value) {
                      setModalState(() {
                        _repeatEndDate = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isRepeatConfigured = true;
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
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttachmentSection() {
    return _selectedImage == null
        ? GestureDetector(
          onTap: _showAttachmentOptions,
          child: Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.grey[100],
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  "Add attachment",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        )
        : Stack(
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: _removeAttachment,
                child: CircleAvatar(
                  radius: 12.r,
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
  }

  // Add this method to show camera/gallery options
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentOption(Icons.camera_alt, "Camera", () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
                  _buildAttachmentOption(Icons.image, "Image", () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
                  _buildAttachmentOption(
                    Icons.insert_drive_file,
                    "Document",
                    () {
                      Navigator.pop(context);
                      // Implement document picker functionality
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: Icon(icon, color: Colors.purple, size: 28.r),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
