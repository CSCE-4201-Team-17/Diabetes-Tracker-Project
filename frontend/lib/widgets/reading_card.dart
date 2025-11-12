import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/glucose_reading.dart';

Widget buildReadingCard(BloodSugarReading reading) {
  Color getBloodSugarColor(double value) {
    if (value < 70) return Colors.orange;
    if (value <= 140) return Colors.green;
    if (value <= 180) return Colors.orange;
    return Colors.red;
  }

  String getBloodSugarStatus(double value) {
    if (value < 70) return 'Low';
    if (value <= 140) return 'Normal';
    if (value <= 180) return 'High';
    return 'Very High';
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: getBloodSugarColor(reading.value).withOpacity(0.2),
        child: Icon(Icons.monitor_heart, color: getBloodSugarColor(reading.value)),
      ),
      title: Text('${reading.value} mg/dL'),
      subtitle: Text('${reading.type} • ${formatDateTime(reading.timestamp)}'),
      trailing: Text(
        getBloodSugarStatus(reading.value),
        style: TextStyle(
          color: getBloodSugarColor(reading.value),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}