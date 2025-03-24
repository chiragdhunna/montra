import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _expenseAlert = true;
  bool _budgetAlert = true;
  bool _tipsArticles = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNotificationTile(
              title: "Expense Alert",
              subtitle: "Get notification about your expense",
              value: _expenseAlert,
              onChanged: (val) {
                setState(() {
                  _expenseAlert = val;
                });
              },
            ),
            _buildNotificationTile(
              title: "Budget",
              subtitle: "Get notification when your budget exceeds the limit",
              value: _budgetAlert,
              onChanged: (val) {
                setState(() {
                  _budgetAlert = val;
                });
              },
            ),
            _buildNotificationTile(
              title: "Tips & Articles",
              subtitle: "Small & useful pieces of practical financial advice",
              value: _tipsArticles,
              onChanged: (val) {
                setState(() {
                  _tipsArticles = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.purple,
      ),
    );
  }
}
