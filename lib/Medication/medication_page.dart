import 'package:flutter/material.dart';
import 'package:health_app/Medication/create_medication_page.dart';
import 'package:health_app/Medication/edit_medication_page.dart';

class MedicationPage extends StatefulWidget {
  final List<Medication> savedMedications;

  const MedicationPage({super.key, required this.savedMedications});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  void _editMedication(int index, Medication updatedMed) {
    setState(() {
      widget.savedMedications[index] = updatedMed;
    });
  }

  //functions
  String _calculateReorderSuggestion(Medication med) {
    print("numRemaining: ${med.numRemaining}, reminderLevel: ${med.reminderLevel}");
    if (med.numRemaining <= med.reminderLevel) {
      return "⚠️ Time to reorder soon!";
    } else {
      return "✔️ You're good for now!";
    }
  }

  //builds
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medications')),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(children: [_createMedication(), _showMedications()]),
    );
  }

  //widgets

  /* Needs Fixed -- 
  Build a homepage button to go straight to viewing medication
  fix dosage logic - specify if tablets or liquid
  so num tablets vs ml
*/
  Widget _showMedications() {
    return Column(
      children: [
        ...widget.savedMedications.asMap().entries.map((entry) {
          final index = entry.key;
          final med = entry.value;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "${med.name}: Taking ${med.dosage} ${med.medType}\n${med.frequency} times per ${med.frequencyType} ",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  subtitle: Text(
                    "A stock of ${med.numRemaining} gives you X remaining doses.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                _editMedicationButton(context, med, index),
                //edit button goes here
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _calculateReorderSuggestion(med),
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _createMedication() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateMedication(
              savedMedications: widget.savedMedications,
              onSave: (newMed) {
                setState(() {
                  widget.savedMedications.add(newMed);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Medication Added!")),
                );
              },
            ),
          ),
        );
      },
      child: const Text("Add Medication"),
    );
  }

  Widget _editMedicationButton(
    BuildContext context,
    Medication med,
    int index,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditMedicationPage(
              medication: med,
              onSave: (updatedMed) => _editMedication(index, updatedMed),
            ),
          ),
        );
      },
      child: const Text("Edit"),
    );
  }
}

//classes
class Medication {
  final String name;
  final String medType;
  final int dosage;
  final int frequency;
  final String frequencyType;
  final int numRemaining;

  final num reminderLevel;

  Medication({
    required this.name,
        required this.medType,
    required this.dosage,
    required this.frequency,
    required this.frequencyType,
    required this.numRemaining,
    required this.reminderLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'medType': medType,
      'dosage': dosage,
      'frequency': frequency,
      'frequencyType': frequencyType,
      'numRemaining': numRemaining,
      'reminderLevel': reminderLevel,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'],
      medType: map['medType'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      frequencyType: map['frequencyType'],
      numRemaining: map['numRemaining'],
      reminderLevel: map['reminderLevel'],
    );
  }

  void add(Medication newMed) {}
}
