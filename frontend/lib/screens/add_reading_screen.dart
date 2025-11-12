import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';

class AddReadingScreen extends StatefulWidget {
  final Function(BloodSugarReading) onReadingAdded;

  const AddReadingScreen({super.key, required this.onReadingAdded});

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final TextEditingController _valueController = TextEditingController();
  String _selectedType = 'Fasting';
  final List<String> _types = ['Fasting', 'Before Meal', 'After Meal', 'Bedtime'];
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitReading() {
    final value = double.tryParse(_valueController.text);
    if (value != null) {
      final reading = BloodSugarReading(
        value: value,
        timestamp: DateTime.now(),
        type: _selectedType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      widget.onReadingAdded(reading);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added reading: $value mg/dL')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blood Sugar Reading'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitReading,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Blood Sugar (mg/dL)',
                prefixIcon: Icon(Icons.monitor_heart),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _types.map((type) => 
                DropdownMenuItem(value: type, child: Text(type))
              ).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              decoration: const InputDecoration(
                labelText: 'Reading Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitReading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}