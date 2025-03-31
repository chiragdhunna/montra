import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/blocs/notification_bloc/notification_bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, String>> _notifications = [];
  late StreamSubscription<NotificationState> notificationStreamSubscription;
  bool isLoading = false;

  void _markAllAsRead() {
    BlocProvider.of<NotificationBloc>(
      context,
    ).add(NotificationEvent.clearAllNotifications());
  }

  void _removeAllNotifications() {
    BlocProvider.of<NotificationBloc>(
      context,
    ).add(NotificationEvent.clearAllNotifications());
  }

  @override
  void initState() {
    super.initState();
    notificationStreamSubscription = BlocProvider.of<NotificationBloc>(
      context,
    ).stream.listen(notificationOnChange);
    BlocProvider.of<NotificationBloc>(
      context,
    ).add(NotificationEvent.getAllNotifications());
  }

  @override
  void dispose() {
    // Cancel stream subscription to prevent memory leaks
    notificationStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> notificationOnChange(NotificationState state) async {
    state.maybeWhen(
      orElse: () {},
      inProgress: () {
        if (!mounted) return;
        setState(() {
          isLoading = true;
        });
      },
      failure: (error) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        });
      },
      getAllNotificationSuccess: (data) {
        if (!mounted) return;

        setState(() {
          try {
            // Clear existing notifications first to avoid duplicates
            _notifications.clear();

            // Handle the case where data might be null
            if (data != null) {
              for (final item in data) {
                if (item is Map) {
                  // Format the notification to match the required structure
                  String title = item['title']?.toString() ?? '';
                  String subtitle = item['subtitle']?.toString() ?? '';

                  // Format time string - if it's a full ISO date string, extract just the time part
                  String timeStr = item['time']?.toString() ?? '';
                  String formattedTime = timeStr;

                  // If time is in ISO format (like "2025-03-30T19:33:37.507Z"), extract just HH:MM
                  if (timeStr.contains('T')) {
                    try {
                      DateTime dateTime = DateTime.parse(timeStr);
                      formattedTime =
                          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                    } catch (e) {
                      // If parsing fails, keep the original string
                      print("Error parsing date: $e");
                    }
                  }

                  _notifications.add({
                    "title": title,
                    "subtitle": subtitle,
                    "time": formattedTime,
                  });
                }
              }
            }

            isLoading = false;
          } catch (e) {
            print("Error processing notifications: $e");
          }
        });
      },
    );
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
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
                        notification["title"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(notification["subtitle"] ?? ""),
                      trailing: Text(
                        notification["time"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
