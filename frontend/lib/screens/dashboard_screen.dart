import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/reading_card.dart';
import '../widgets/action_card.dart';
import '../widgets/glucose_chart.dart';

class DashboardScreen extends StatefulWidget {
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

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<BloodSugarReading> _readings = [];
  Map<String, dynamic> _weeklySummary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = StorageService.userId;
      if (userId != null) {
        // Load data from API
        final readings = await ApiService.getGlucoseReadings(userId);
        final summary = await ApiService.getWeeklySummary(userId);
        
        setState(() {
          _readings = readings;
          _weeklySummary = summary;
          _isLoading = false;
        });
      } else {
        // Fallback to local data if no user ID
        setState(() {
          _readings = widget.bloodSugarReadings;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to local data on error
      setState(() {
        _readings = widget.bloodSugarReadings;
        _isLoading = false;
      });
    }
  }

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

  double _calculateTimeInRange() {
    if (_readings.isEmpty) return 0.0;
    
    final inRange = _readings.where((reading) => 
      reading.value >= 70 && reading.value <= 140).length;
    
    return (inRange / _readings.length) * 100;
  }

  double _calculateAverageGlucose() {
    if (_readings.isEmpty) return 0.0;
    final total = _readings.map((r) => r.value).reduce((a, b) => a + b);
    return total / _readings.length;
  }

  Widget _buildStatsGrid() {
    final latestReading = _readings.isNotEmpty ? _readings.first : null;
    final todayReadings = _readings.where((reading) => 
      reading.timestamp.day == DateTime.now().day).toList();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        buildStatCard(
          'Current Glucose',
          latestReading?.value.toStringAsFixed(0) ?? '--',
          'mg/dL',
          latestReading != null ? _getBloodSugarColor(latestReading.value) : Colors.grey,
        ),
        buildStatCard(
          'Time in Range',
          '${_calculateTimeInRange().toStringAsFixed(0)}%',
          '70-140 mg/dL',
          Colors.green,
        ),
        buildStatCard(
          'Average',
          '${_calculateAverageGlucose().toStringAsFixed(0)}',
          'mg/dL',
          Colors.blue,
        ),
        buildStatCard(
          'Readings Today',
          todayReadings.length.toString(),
          'records',
          Colors.orange,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
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
            
            // Quick Stats
            const Text(
              'Today\'s Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatsGrid(),
            
            const SizedBox(height: 20),
            
            // Glucose Chart
            if (_readings.isNotEmpty)
              Column(
                children: [
                  SimpleGlucoseChart(readings: _readings),
                  const SizedBox(height: 20),
                ],
              ),
            
            // Quick Actions
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
                buildActionCard('Log Blood Sugar', Icons.monitor_heart, Colors.red, widget.onAddBloodSugar),
                buildActionCard('Medications', Icons.medication, Colors.green, widget.onNavigateToMedications),
                buildActionCard('History', Icons.history, Colors.orange, widget.onNavigateToHistory),
                buildActionCard('Settings', Icons.settings, Colors.purple, widget.onNavigateToSettings),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Recent Readings
            const Text(
              'Recent Readings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (_readings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No readings yet. Add your first reading!'),
                ),
              )
            else
              ..._readings.take(3).map((reading) => 
                buildReadingCard(reading)
              ).toList(),

            // AI Insights
            if (_weeklySummary['insights'] != null)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.insights, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Weekly Insights',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_weeklySummary['insights'] ?? 'No insights available yet.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}