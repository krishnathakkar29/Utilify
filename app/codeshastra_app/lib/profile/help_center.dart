import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
        title: Text('Help Center', style: TextStyle(color: theme.primaryColor)),
        backgroundColor: theme.primaryColorDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection('Frequently Asked Questions', [
            _buildExpansionTile(
              'How do I change my password?',
              'Go to Profile > Security > Change Password to update your password.',
              theme,
            ),
            _buildExpansionTile(
              'How do I update my profile?',
              'Go to Profile > Personal Information to update your profile details.',
              theme,
            ),
          ], theme),
          _buildHelpSection('Contact Support', [
            _buildContactTile(
              'Email Support',
              'support@example.com',
              Icons.email,
              theme,
            ),
            _buildContactTile(
              'Live Chat',
              'Start a conversation',
              Icons.chat_bubble_outline,
              theme,
            ),
          ], theme),
        ],
      ),
    );
  }

  Widget _buildHelpSection(
    String title,
    List<Widget> children,
    ThemeData theme,
  ) {
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
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpansionTile(String title, String content, ThemeData theme) {
    return Card(
      color: theme.primaryColor.withOpacity(0.1),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(color: theme.primaryColor)),
        iconColor: theme.primaryColor,
        collapsedIconColor: theme.primaryColor,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: TextStyle(color: theme.primaryColor.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme,
  ) {
    return Card(
      color: theme.primaryColor.withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: theme.primaryColor),
        title: Text(title, style: TextStyle(color: theme.primaryColor)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: theme.primaryColor.withOpacity(0.8)),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.primaryColor),
        onTap: () {
          // Handle contact option
        },
      ),
    );
  }
}
