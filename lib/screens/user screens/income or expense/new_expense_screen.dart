import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  String? _selectedCategory;
  String? _selectedWallet;
  bool _isRepeat = false;
  File? _selectedImage;

  final List<String> _categories = [
    "Food",
    "Shopping",
    "Transport",
    "Subscription",
  ];
  final List<String> _wallets = ["Bank", "Cash", "Credit Card", "Paypal"];

  bool _isRepeatConfigured = false;
  String _repeatFrequency = "Yearly";
  String _repeatMonth = "Dec";
  String _repeatDay = "29";
  String _repeatEndDate = "29 Dec 2025";

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

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

  void _removeAttachment() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Expense",
          style: TextStyle(
            fontSize: 18,
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
            "How much?",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "\$80",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownField(
                    "Subscription",
                    _selectedCategory,
                    _categories,
                    (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField("Disney+ annual subscription"),
                  const SizedBox(height: 15),
                  _buildDropdownField("Paypal", _selectedWallet, _wallets, (
                    value,
                  ) {
                    setState(() {
                      _selectedWallet = value;
                    });
                  }),
                  Spacer(),
                  _buildAttachmentSection(),
                  Spacer(),
                  _buildRepeatTransactionToggle(),
                  const Spacer(),
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
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Implement expense submission logic
        },
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
}
