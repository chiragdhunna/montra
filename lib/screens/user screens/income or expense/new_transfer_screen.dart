import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NewTransferScreen extends StatefulWidget {
  const NewTransferScreen({super.key});

  @override
  State<NewTransferScreen> createState() => _NewTransferScreenState();
}

class _NewTransferScreenState extends State<NewTransferScreen> {
  String? _selectedFromWallet;
  String? _selectedToWallet;
  File? _selectedImage;

  final List<String> _wallets = ["Bank", "Cash", "Credit Card", "Paypal"];

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

  void _showSuccessDialog() {
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Transfer",
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
            "\$0",
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
                  _buildWalletSelection(),
                  const SizedBox(height: 15),
                  _buildTextField("Description"),
                  const SizedBox(height: 15),
                  _buildAttachmentSection(),
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

  Widget _buildWalletSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField("From", _selectedFromWallet, _wallets, (
            value,
          ) {
            setState(() {
              _selectedFromWallet = value;
            });
          }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: Icon(Icons.swap_horiz, color: Colors.purple, size: 20.r),
          ),
        ),
        Expanded(
          child: _buildDropdownField("To", _selectedToWallet, _wallets, (
            value,
          ) {
            setState(() {
              _selectedToWallet = value;
            });
          }),
        ),
      ],
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
