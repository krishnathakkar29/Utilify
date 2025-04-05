import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'PDF Created Successfully',
      message: 'Your PDF has been generated and saved',
      time: '2 mins ago',
      icon: Icons.picture_as_pdf,
      color: Colors.blue,
    ),
    NotificationItem(
      title: 'QR Code Generated',
      message: 'QR Code has been created and saved to gallery',
      time: '15 mins ago',
      icon: Icons.qr_code,
      color: Colors.green,
    ),
    NotificationItem(
      title: 'File Conversion Complete',
      message: 'Your document has been converted successfully',
      time: '1 hour ago',
      icon: Icons.file_copy,
      color: Colors.orange,
    ),
    NotificationItem(
      title: 'Storage Warning',
      message: 'Your storage is running low',
      time: '2 hours ago',
      icon: Icons.storage,
      color: Colors.red,
    ),
  ];

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
          child: Icon(Icons.arrow_back, color: theme.primaryColor),
        ),
        centerTitle: true,
        title: Text(
          'Notifications & Alerts',
          style: TextStyle(color: theme.primaryColor, fontSize: 24),
        ),
        backgroundColor: theme.primaryColorDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.primaryColor),
            onPressed: () {
              // Clear all notifications
              setState(() => notifications.clear());
            },
          ),
        ],
      ),
      body:
          notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: theme.primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        color: theme.primaryColor.withOpacity(0.5),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: notifications.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Dismissible(
                    key: Key(notification.title),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        notifications.removeAt(index);
                      });
                    },
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notification.color.withOpacity(0.2),
                          child: Icon(
                            notification.icon,
                            color: notification.color,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notification.message),
                            const SizedBox(height: 4),
                            Text(
                              notification.time,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          // Handle notification tap
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}
