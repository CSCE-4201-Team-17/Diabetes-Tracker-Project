import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';
import 'dashboard_screen.dart';
import 'medications_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'ai_assistant_screen.dart';
import 'meal_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<BloodSugarReading> _bloodSugarReadings = [];
  final List<Medication> _medications = [
    Medication(name: 'Metformin', dosage: '500mg', hour: 8, minute: 0),
    Medication(name: 'Insulin', dosage: '10 units', hour: 20, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _bloodSugarReadings.addAll([
      BloodSugarReading(value: 120, timestamp: DateTime.now().subtract(const Duration(hours: 2)), type: 'After Meal'),
      BloodSugarReading(value: 95, timestamp: DateTime.now().subtract(const Duration(days: 1)), type: 'Fasting'),
      BloodSugarReading(value: 140, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)), type: 'After Meal'),
    ]);
  }

  //Dashboard Screen
  Widget _buildDashboard() {
    return DashboardScreen(
      bloodSugarReadings: _bloodSugarReadings,
      medications: _medications,
      onAddBloodSugar: _showAddBloodSugarDialog,
      onNavigateToMedications: () => setState(() => _currentIndex = 3),
      onNavigateToHistory: () => setState(() => _currentIndex = 4),
      onNavigateToSettings: () => setState(() => _currentIndex = 5),
    );
  }

  //AI Assistant Screen
  Widget _buildAiAssistant() {
    return AiAssistantScreen(
      bloodSugarReadings: _bloodSugarReadings,
      medications: _medications,
    );
  }

  //Medications Screen
  Widget _buildMedications() {
    return MedicationsScreen(
      medications: _medications,
      onAddMedication: _showAddMedicationDialog,
      onUpdateMedication: (index, taken) {
        setState(() {
          final medication = _medications[index];
          _medications[index] = Medication(
            name: medication.name,
            dosage: medication.dosage,
            hour: medication.hour,
            minute: medication.minute,
            taken: taken,
          );
        });
      },
    );
  }

  //History Screen
  Widget _buildHistory() {
    return HistoryScreen(
      bloodSugarReadings: _bloodSugarReadings,
      onAddBloodSugar: _showAddBloodSugarDialog,
    );
  }

  //Settings Screen
  Widget _buildSettings() {
    return SettingsScreen(
      onLogout: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
    );
  }

  //Meal Upload Screen
  Widget _buildMealUpload() {
    return const MealUploadScreen();
  }

  //Dialog Methods
  void _showAddBloodSugarDialog() {
    final TextEditingController valueController = TextEditingController();
    String selectedType = 'Fasting';
    final List<String> types = ['Fasting', 'Before Meal', 'After Meal', 'Bedtime'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blood Sugar Reading'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Blood Sugar (mg/dL)',
                prefixIcon: Icon(Icons.monitor_heart),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: types.map((type) => 
                DropdownMenuItem(value: type, child: Text(type))
              ).toList(),
              onChanged: (value) => selectedType = value!,
              decoration: const InputDecoration(labelText: 'Reading Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(valueController.text);
              if (value != null) {
                setState(() {
                  _bloodSugarReadings.insert(0, BloodSugarReading(
                    value: value,
                    timestamp: DateTime.now(),
                    type: selectedType,
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added reading: $value mg/dL')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add medication feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),  //adds the different tabs in the bottom of dashboard
          _buildAiAssistant(),
          _buildMedications(),
          _buildHistory(),
          _buildSettings(),
          _buildMealUpload(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Coach'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medications'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Log Meal'), // ADD THIS
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: _showAddBloodSugarDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}