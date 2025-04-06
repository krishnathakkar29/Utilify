import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColorDark,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Security', style: TextStyle(color: theme.primaryColor)),
        backgroundColor: theme.primaryColorDark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Password', [
                ListTile(
                  leading: Icon(Icons.lock_outline, color: theme.primaryColor),
                  title: Text(
                    'Change Password',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.primaryColor,
                  ),
                  onTap: () {
                    // Navigate to change password screen
                  },
                ),
              ], theme),
              _buildSection('Two-Factor Authentication', [
                SwitchListTile(
                  secondary: Icon(Icons.security, color: theme.primaryColor),
                  title: Text(
                    'Enable 2FA',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  subtitle: Text(
                    'Add an extra layer of security',
                    style: TextStyle(
                      color: theme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                  value: _twoFactorEnabled,
                  onChanged: (value) {
                    setState(() => _twoFactorEnabled = value);
                  },
                  activeColor: theme.primaryColor,
                ),
              ], theme),
              _buildSection('Login History', [
                ListTile(
                  leading: Icon(Icons.history, color: theme.primaryColor),
                  title: Text(
                    'Recent Devices',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.primaryColor,
                  ),
                  onTap: () {
                    // Show login history
                  },
                ),
              ], theme),
            ],
          ),
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
}
