import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/reading_card.dart';

class HistoryScreen extends StatefulWidget {
  final List<BloodSugarReading> bloodSugarReadings;
  final VoidCallback onAddBloodSugar;

  const HistoryScreen({
    super.key,
    required this.bloodSugarReadings,
    required this.onAddBloodSugar,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<BloodSugarReading> _readings = [];
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
        final readings = await ApiService.getGlucoseReadings(userId);
        setState(() {
          _readings = readings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _readings = widget.bloodSugarReadings;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _readings = widget.bloodSugarReadings;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                  onPressed: widget.onAddBloodSugar,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reading'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: _readings.isEmpty
                    ? const Center(
                        child: Text('No readings yet. Add your first reading!'),
                      )
                    : ListView.builder(
                        itemCount: _readings.length,
                        itemBuilder: (context, index) {
                          return buildReadingCard(_readings[index]);
                        },
                      ),
              ),
            ),
        ],
      ),
    );
  }
}