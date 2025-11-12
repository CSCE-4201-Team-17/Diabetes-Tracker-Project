import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/glucose_reading.dart';
import '../widgets/reading_card.dart';

class HistoryScreen extends StatelessWidget {
  final List<BloodSugarReading> bloodSugarReadings;
  final VoidCallback onAddBloodSugar;

  const HistoryScreen({
    super.key,
    required this.bloodSugarReadings,
    required this.onAddBloodSugar,
  });

  Color _getBloodSugarColor(double value) {
    if (value < 70) return Colors.orange;
    if (value <= 140) return Colors.green;
    if (value <= 180) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  Widget _buildReadingCard(BloodSugarReading reading) {
    String getBloodSugarStatus(double value) {
      if (value < 70) return 'Low';
      if (value <= 140) return 'Normal';
      if (value <= 180) return 'High';
      return 'Very High';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getBloodSugarColor(reading.value).withOpacity(0.2),
          child: Icon(Icons.monitor_heart, color: _getBloodSugarColor(reading.value)),
        ),
        title: Text('${reading.value} mg/dL'),
        subtitle: Text('${reading.type} • ${_formatDateTime(reading.timestamp)}'),
        trailing: Text(
          getBloodSugarStatus(reading.value),
          style: TextStyle(
            color: _getBloodSugarColor(reading.value),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Blood Sugar History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: onAddBloodSugar,
                icon: const Icon(Icons.add),
                label: const Text('Add Reading'),
              ),
            ],
          ),
        ),
        Expanded(
          child: bloodSugarReadings.isEmpty
              ? const Center(
                  child: Text('No readings yet. Add your first reading!'),
                )
              : ListView.builder(
                  itemCount: bloodSugarReadings.length,
                  itemBuilder: (context, index) {
                    return _buildReadingCard(bloodSugarReadings[index]);
                  },
                ),
        ),
      ],
    );
  }
}