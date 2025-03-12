import 'package:flutter/material.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _selectedTheme = "Light";

  final List<String> _themes = ["Light", "Dark", "Use device theme"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: _themes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_themes[index]),
            trailing:
                _selectedTheme == _themes[index]
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
            onTap: () {
              setState(() {
                _selectedTheme = _themes[index];
              });
            },
          );
        },
      ),
    );
  }
}
