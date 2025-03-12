import 'package:flutter/material.dart';
import 'package:montra/screens/user%20screens/profile%20section/settings%20screens/currency_screen.dart';
import 'package:montra/screens/user%20screens/profile%20section/settings%20screens/language_screen.dart';
import 'package:montra/screens/user%20screens/profile%20section/settings%20screens/notification_screen.dart';
import 'package:montra/screens/user%20screens/profile%20section/settings%20screens/security_screen.dart';
import 'package:montra/screens/user%20screens/profile%20section/settings%20screens/theme_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _launchURL() async {
    final Uri _url = Uri.parse('https://github.com/chiragdhunna/montra');
    try {
      if (await canLaunchUrl(_url)) {
        await launchUrl(_url, mode: LaunchMode.externalApplication);
      } else {
        // Show a more user-friendly error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch the URL')));
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while trying to open the URL'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSettingsItem(
              title: 'Currency',
              value: 'USD',
              onTap: () {
                // Handle currency tap
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) => CurrencyScreen()),
                );
              },
            ),
            const Divider(height: 1),
            _buildSettingsItem(
              title: 'Language',
              value: 'English',
              onTap: () {
                // Handle language tap
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) => LanguageScreen()),
                );
              },
            ),
            const Divider(height: 1),
            _buildSettingsItem(
              title: 'Theme',
              value: 'Dark',
              onTap: () {
                // Handle theme tap
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (builder) => ThemeScreen()));
              },
            ),
            const Divider(height: 1),
            _buildSettingsItem(
              title: 'Security',
              value: 'Fingerprint',
              onTap: () {
                // Handle security tap
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) => SecurityScreen()),
                );
              },
            ),
            const Divider(height: 1),
            _buildSettingsItem(
              title: 'Notification',
              value: '',
              onTap: () {
                // Handle notification tap
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) => NotificationScreen()),
                );
              },
            ),
            const Divider(height: 1),
            _buildSettingsItem(title: 'About', value: '', onTap: _launchURL),
            const Divider(height: 1),
            _buildSettingsItem(title: 'Help', value: '', onTap: _launchURL),
            const Divider(height: 1),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 20,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
        ),
        child: Center(
          child: Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.purple.shade400),
        ],
      ),
      onTap: onTap,
    );
  }
}
