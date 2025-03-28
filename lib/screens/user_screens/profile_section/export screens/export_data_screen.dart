import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/blocs/export_data/export_data_bloc.dart';
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

  final List<String> dataTypes = [
    'All',
    'Income',
    'Expense',
    'Transfer',
    'Budget',
  ];
  final List<String> dateRanges = [
    'Last 30 days',
    'Last Quarter',
    '6 months',
    'Last Year',
  ];
  final List<String> formats = ['CSV', 'PDF'];

  String _mapDateRangeToKey(String range) {
    switch (range) {
      case 'Last Year':
        return 'lastYear';
      case 'Last Quarter':
        return 'lastQuarter';
      case '6 months':
        return '6months';
      default:
        return '1month'; // Last 30 days
    }
  }

  bool _isLoading = false;

  late StreamSubscription<ExportDataState> exportDataSubscription;

  @override
  void initState() {
    // TODO: implement initState
    exportDataSubscription = BlocProvider.of<ExportDataBloc>(
      context,
    ).stream.listen(exportDataOnChangeHandler);
    super.initState();
  }

  Future<void> exportDataOnChangeHandler(ExportDataState state) async {
    state.maybeWhen(
      orElse: () {},
      getExportDataSuccess: (filePath) {
        setState(() {
          _isLoading = false;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (builder) => ExportDataSuccessScreen()),
          );
        });
      },
      failure: (error) {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error : $error')));
        });
      },
      inProgress: () {
        setState(() {
          _isLoading = true;
        });
      },
    );
  }

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
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What data do your want to export?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: selectedDataType,
                        items: dataTypes,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: selectedDateRange,
                        items: dateRanges,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: selectedFormat,
                        items: formats,
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
                            BlocProvider.of<ExportDataBloc>(context).add(
                              ExportDataEvent.getExportData(
                                dataType: selectedDataType.toLowerCase(),
                                dateRange: _mapDateRangeToKey(
                                  selectedDateRange,
                                ),
                                format: selectedFormat.toLowerCase(),
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
    required List<String> items,
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
        items:
            items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
