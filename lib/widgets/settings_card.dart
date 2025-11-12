import 'package:flutter/material.dart';

Widget buildSettingsCard(String title, IconData icon, List<Widget> children) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...children,
      ],
    ),
  );
}