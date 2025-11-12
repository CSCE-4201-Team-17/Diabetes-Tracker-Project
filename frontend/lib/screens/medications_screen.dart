import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationsScreen extends StatelessWidget {
  final List<Medication> medications;
  final VoidCallback onAddMedication;
  final Function(int, bool) onUpdateMedication;

  const MedicationsScreen({
    super.key,
    required this.medications,
    required this.onAddMedication,
    required this.onUpdateMedication,
  });

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
                'Your Medications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onAddMedication,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.green),
                  title: Text(medication.name),
                  subtitle: Text('${medication.dosage} • ${medication.timeString}'),
                  trailing: Checkbox(
                    value: medication.taken,
                    onChanged: (value) {
                      onUpdateMedication(index, value ?? false);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}