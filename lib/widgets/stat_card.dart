import 'package:flutter/material.dart';

Widget buildStatCard(String title, String value, String unit, Color color) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: color)),
            ],
          ),
        ],
      ),
    ),
  );
}