import 'package:flutter/material.dart';
import 'package:montra/screens/user_screens/profile_section/export%20screens/export_data_success_screen.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  String selectedDataType = 'All';
  String selectedDateRange = 'Last 30 days';
  String selectedFormat = 'CSV';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What data do your want to export?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: selectedDataType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDataType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'When date range?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: selectedDateRange,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDateRange = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'What format do you want to export?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: selectedFormat,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFormat = value;
                    });
                  }
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle export action
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (builder) => ExportDataSuccessScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E57FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.download, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Export',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: [DropdownMenuItem(value: value, child: Text(value))],
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
