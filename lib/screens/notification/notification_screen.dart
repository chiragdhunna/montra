import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> _notifications = [
    {
      "title": "Shopping Budget has exceeded",
      "subtitle": "Your Shopping budget has exceeded the limit...",
      "time": "19:30",
    },
    {
      "title": "Utilities budget has exceeded",
      "subtitle": "Your Utilities budget has exceeded the limit...",
      "time": "19:30",
    },
  ];

  void _markAllAsRead() {
    setState(() {
      // Here, we can add logic if needed to differentiate read/unread items
    });
  }

  void _removeAllNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == "mark_read") {
                _markAllAsRead();
              } else if (value == "remove_all") {
                _removeAllNotifications();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: "mark_read",
                    child: Text("Mark all read"),
                  ),
                  const PopupMenuItem(
                    value: "remove_all",
                    child: Text("Remove all"),
                  ),
                ],
          ),
        ],
      ),
      body:
          _notifications.isEmpty
              ? const Center(
                child: Text(
                  "There is no notification for now",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        notification["title"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(notification["subtitle"]!),
                      trailing: Text(
                        notification["time"]!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
