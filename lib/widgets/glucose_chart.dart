import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';

class SimpleGlucoseChart extends StatelessWidget {
  final List<BloodSugarReading> readings;
  
  const SimpleGlucoseChart({super.key, required this.readings});
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
  
  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No readings yet. Add your first reading!'),
        ),
      );
    }

    //Sort by timestamp
    final sortedReadings = List<BloodSugarReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Glucose Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTrendVisualization(sortedReadings),
            const SizedBox(height: 16),
            _buildReadingsTable(sortedReadings),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrendVisualization(List<BloodSugarReading> readings) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: readings.length,
        itemBuilder: (context, index) {
          final reading = readings[index];
          return _buildTrendBar(reading, index, readings.length);
        },
      ),
    );
  }
  
  Widget _buildTrendBar(BloodSugarReading reading, int index, int total) {
    Color getColor(double value) {
      if (value < 70) return Colors.orange;
      if (value <= 140) return Colors.green;
      if (value <= 180) return Colors.orange;
      return Colors.red;
    }
    
    //Normalize height (assuming max glucose of 300 for visualization)
    final height = (reading.value / 300 * 80).clamp(10.0, 80.0);
    final width = 40.0;
    
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          Text(
            reading.value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10,
              color: getColor(reading.value),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: getColor(reading.value),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(reading.timestamp),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReadingsTable(List<BloodSugarReading> readings) {
    return Column(
      children: readings.take(5).map((reading) => _buildReadingRow(reading)).toList(),
    );
  }
  
  Widget _buildReadingRow(BloodSugarReading reading) {
    Color getColor(double value) {
      if (value < 70) return Colors.orange;
      if (value <= 140) return Colors.green;
      if (value <= 180) return Colors.orange;
      return Colors.red;
    }
    
    String getStatus(double value) {
      if (value < 70) return 'Low';
      if (value <= 140) return 'Normal';
      if (value <= 180) return 'High';
      return 'Very High';
    }
    
    String formatDateTime(DateTime dateTime) {
      return '${dateTime.month}/${dateTime.day} ${_formatTime(dateTime)}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${reading.value} mg/dL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: getColor(reading.value),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              getStatus(reading.value),
              style: TextStyle(
                color: getColor(reading.value),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatDateTime(reading.timestamp),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              reading.type,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}