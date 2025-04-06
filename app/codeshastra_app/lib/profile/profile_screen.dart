import 'package:codeshastra_app/profile/help_center.dart';
import 'package:codeshastra_app/profile/personal_information.dart';
import 'package:codeshastra_app/profile/report_bu.dart';
import 'package:codeshastra_app/profile/security.dart';
import 'package:codeshastra_app/razorpay.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  bool _isDarkMode = false;
  final _formKey = GlobalKey<FormState>();

  // Mock user data - Replace with actual user data
  Map<String, dynamic> userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'username': '@johndoe',
    'bio': 'Flutter Developer | Tech Enthusiast',
    'subscription': 'Free Trial',
    'notifications': true,
  };

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // backgroundColor: Theme.of(context).primaryColorDark,
  //       appBar: AppBar(
  //         leading: GestureDetector(
  //           onTap: () {
  //             Navigator.pop(context);
  //           },
  //           child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
  //         ),
  //         centerTitle: true,
  //         title: Text(
  //           'Video Converter',
  //           style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
  //         ),
  //         backgroundColor: Theme.of(context).primaryColorDark,
  //       ),
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColorDark,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        title: Text('Profile', style: TextStyle(color: theme.primaryColor)),
        backgroundColor: Theme.of(context).primaryColorDark,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: theme.primaryColorDark),
            onPressed: () {
              // Add logout logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : const AssetImage('assets/avatar.jpg'),
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: theme.primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  Text(
                    userData['username'],
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData['bio'],
                    style: TextStyle(
                      color: theme.primaryColor.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Account', [
                    _buildTile(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalInformationScreen(),
                          ),
                        );
                        // Navigate to security settings
                      },
                    ),
                    _buildTile(
                      icon: Icons.lock_outline,
                      title: 'Security',
                      subtitle: 'Password, 2FA',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecurityScreen(),
                          ),
                        );
                        // Navigate to security settings
                      },
                    ),
                  ], theme),

                  _buildSection('Preferences', [
                    // _buildSwitchTile(
                    //   icon: Icons.dark_mode_outlined,
                    //   title: 'Dark Mode',
                    //   value: _isDarkMode,
                    //   onChanged: (value) {
                    //     setState(() => _isDarkMode = value);
                    //   },
                    // ),
                    _buildSwitchTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      value: userData['notifications'],
                      onChanged: (value) {
                        setState(() => userData['notifications'] = value);
                      },
                    ),
                  ], theme),

                  _buildSection('Subscription', [
                    _buildTile(
                      icon: Icons.workspace_premium,
                      title: 'Current Plan',
                      subtitle: userData['subscription'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(),
                          ),
                        );
                        // Navigate to subscription details
                      },
                    ),
                  ], theme),

                  _buildSection('Support', [
                    _buildTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelpCenterScreen(),
                          ),
                        );
                        // Navigate to help center
                      },
                    ),
                    _buildTile(
                      icon: Icons.bug_report_outlined,
                      title: 'Report a Bug',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportBugScreen(),
                          ),
                        );
                      },
                    ),
                  ], theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                ),
              )
              : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).primaryColor.withOpacity(0.6),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}
