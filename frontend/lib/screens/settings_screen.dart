import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        buildSettingsCard(
          'Profile',
          Icons.person,
          [
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('user@example.com'),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+1 234 567 8900'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text(
                      'Preferences',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Enable Reminders'),
                value: StorageService.enableReminders,
                onChanged: (value) async {
                  await StorageService.setEnableReminders(value);
                  if (value) {
                    await NotificationService.scheduleDailyReminders();
                  } else {
                    await NotificationService.cancelAllNotifications();
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: StorageService.darkMode,
                onChanged: (value) async {
                  await StorageService.setDarkMode(value);
                  //Need to add theme switching logic here later
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.medical_information),
                title: Text('Medical Information'),
                subtitle: Text('Manage your health data'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}