import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';
import '../widgets/stat_card.dart';
import '../widgets/reading_card.dart';
import '../widgets/action_card.dart';

class DashboardScreen extends StatelessWidget {
  final List<BloodSugarReading> bloodSugarReadings;
  final List<Medication> medications;
  final VoidCallback onAddBloodSugar;
  final VoidCallback onNavigateToMedications;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToSettings;

  const DashboardScreen({
    super.key,
    required this.bloodSugarReadings,
    required this.medications,
    required this.onAddBloodSugar,
    required this.onNavigateToMedications,
    required this.onNavigateToHistory,
    required this.onNavigateToSettings,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Color _getBloodSugarColor(double value) {
    if (value < 70) return Colors.orange;
    if (value <= 140) return Colors.green;
    if (value <= 180) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
    final latestReading = bloodSugarReadings.isNotEmpty ? bloodSugarReadings.first : null;
    final todayReadings = bloodSugarReadings.where((reading) => 
      reading.timestamp.day == DateTime.now().day).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreeting()}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your diabetes management',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          //Quick Stats
          const Text(
            'Today\'s Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: buildStatCard(
                  'Blood Sugar',
                  latestReading?.value.toString() ?? '--',
                  'mg/dL',
                  latestReading != null ? _getBloodSugarColor(latestReading.value) : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildStatCard(
                  'Readings Today',
                  todayReadings.length.toString(),
                  'times',
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          //Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              buildActionCard('Log Blood Sugar', Icons.monitor_heart, Colors.red, onAddBloodSugar),
              buildActionCard('Medications', Icons.medication, Colors.green, onNavigateToMedications),
              buildActionCard('History', Icons.history, Colors.orange, onNavigateToHistory),
              buildActionCard('Settings', Icons.settings, Colors.purple, onNavigateToSettings),
            ],
          ),
          
          const SizedBox(height: 20),
          
          //Recent Readings
          const Text(
            'Recent Readings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (bloodSugarReadings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No readings yet. Add your first reading!'),
              ),
            )
          else
            ...bloodSugarReadings.take(3).map((reading) => 
              _buildReadingCard(reading)
            ).toList(),
        ],
      ),
    );
  }
}