import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/screens/user%20screens/profile%20section/account_screen.dart';
import 'package:montra/screens/user%20screens/profile%20section/export_data_screen.dart';
import 'package:montra/screens/user%20screens/profile%20section/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    'assets/profile.png',
                  ), // Replace with your image asset
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Username', style: TextStyle(color: Colors.grey)),
                    Text(
                      'Iriana Saliha',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    Icons.account_circle,
                    'Account',
                    Colors.purple,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (builder) => AccountScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildListTile(Icons.settings, 'Settings', Colors.purple, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (builder) => SettingsScreen()),
                    );
                  }),
                  _buildDivider(),
                  _buildListTile(
                    Icons.upload,
                    'Export Data',
                    Colors.purple,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (builder) => ExportDataScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildListTile(Icons.logout, 'Logout', Colors.red, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    Color iconColor, [
    VoidCallback? onTap,
  ]) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey,
    );
  }
}
