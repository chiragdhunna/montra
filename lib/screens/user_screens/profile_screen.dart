import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/screens/user_screens/profile_section/account_screen.dart';
import 'package:montra/screens/user_screens/profile_section/export%20screens/export_data_screen.dart';
import 'package:montra/screens/user_screens/profile_section/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthenticationBloc>(context).getAuthUser().then((onValue) {
      setState(() {
        user = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundImage:
                      user!.imgUrl != null && user!.imgUrl!.isNotEmpty
                          ? user!.imgUrl!.startsWith('/')
                              ? FileImage(File(user!.imgUrl!)) as ImageProvider
                              : AssetImage(user!.imgUrl!)
                          : AssetImage("assets/default_avatar.png"),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Username', style: TextStyle(color: Colors.grey)),
                    Text(
                      user!.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
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
                  _buildListTile(Icons.logout, 'Logout', Colors.red, () {
                    _showLogoutBottomSheet(context);
                  }),
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

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Logout?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you wanna logout?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(120, 50),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(120, 50),
                    ),
                    onPressed: () {
                      // Handle logout logic here
                      // Navigator.of(context).pop();
                      BlocProvider.of<AuthenticationBloc>(
                        context,
                      ).add(const AuthenticationEvent.logout());
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
