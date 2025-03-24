import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = "English (EN)";

  final List<String> _languages = [
    "English (EN)",
    "Indonesian (ID)",
    "Arabic (AR)",
    "Chinese (ZH)",
    "Dutch (NL)",
    "French (FR)",
    "German (DE)",
    "Italian (IT)",
    "Korean (KO)",
    "Portuguese (PT)",
    "Russian (RU)",
    "Spanish (ES)",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Language"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_languages[index]),
            trailing:
                _selectedLanguage == _languages[index]
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
            onTap: () {
              setState(() {
                _selectedLanguage = _languages[index];
              });
            },
          );
        },
      ),
    );
  }
}
