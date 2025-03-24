import 'package:flutter/material.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _selectedCurrency = "United States (USD)";

  final List<String> _currencies = [
    "United States (USD)",
    "Indonesia (IDR)",
    "Japan (JPY)",
    "Russia (RUB)",
    "Germany (EUR)",
    "Korea (WON)",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_currencies[index]),
            trailing:
                _selectedCurrency == _currencies[index]
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
            onTap: () {
              setState(() {
                _selectedCurrency = _currencies[index];
              });
            },
          );
        },
      ),
    );
  }
}
