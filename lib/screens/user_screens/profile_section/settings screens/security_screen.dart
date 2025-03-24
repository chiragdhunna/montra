import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String _selectedSecurityOption = "PIN";

  final List<String> _securityOptions = ["PIN", "Fingerprint", "Face ID"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: _securityOptions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_securityOptions[index]),
            trailing:
                _selectedSecurityOption == _securityOptions[index]
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
            onTap: () {
              setState(() {
                _selectedSecurityOption = _securityOptions[index];
              });
            },
          );
        },
      ),
    );
  }
}
