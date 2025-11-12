import 'package:flutter/material.dart';
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
        buildSettingsCard(
          'Preferences',
          Icons.settings,
          [
            SwitchListTile(
              title: const Text('Enable Reminders'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: false,
              onChanged: (value) {},
            ),
          ],
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