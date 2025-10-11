import 'package:flutter/material.dart';

void main() {
  runApp(const DiabetesTrackerApp());
}

class DiabetesTrackerApp extends StatelessWidget {
  const DiabetesTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diabetes Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Track and manage your blood sugar with ease.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Log Blood Sugar Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to Log Screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_chart),
              label: const Text(
                'Log Blood Sugar',
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // View History Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to History Screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.history),
              label: const Text(
                'View History',
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // Settings Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to Settings Screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.settings),
              label: const Text(
                'Settings',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

