import 'package:flutter/material.dart';
import 'package:health_app/UI/Medication/create_medication_page.dart';
import 'package:health_app/UI/Medication/edit_medication_page.dart';
import 'package:health_app/access_rights.dart';

class MedicationPage extends StatefulWidget {
  final List<Medication> savedMedications;

  const MedicationPage({super.key, required this.savedMedications});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

/*
to do :
days remaining reorder isnt working for changing to month/week in the edit tab
or in adding medication - 1 per week with stock of 5 says reorder in 5 days instead of 3 or 4 weeks
ok on selecting liquid dose isnt working

*/
class _MedicationPageState extends State<MedicationPage> {
  final canEditMedications = AccessRights.has('medication', 'edit');

  void _editMedication(int index, Medication updatedMed) {
    setState(() {
      widget.savedMedications[index] = updatedMed;
    });
  }

  //functions
  bool calculateReorderSuggestion(Medication med) {
    final int daysRemaining = calculateDaysRemaining(med);
    if (daysRemaining <= med.reminderLevel) {
      return true;
    } else {
      return false;
    }
  }

  int calculateDosesRemaining(Medication med) {
    if (med.dosage == 0) return 0;
    return (med.numRemaining / med.dosage).floor();
  }

  int calculateDaysRemaining(Medication med) {
    final int dosesPerDay;

    switch (med.frequencyType.toLowerCase()) {
      case "day":
        dosesPerDay = med.frequency;
        break;
      case "week":
        dosesPerDay = (med.frequency / 7).ceil();
        break;
      case "month":
        dosesPerDay = (med.frequency / 30).ceil();
      default:
        dosesPerDay = 1;
    }

    final int daysRemaining = (calculateDosesRemaining(med) / dosesPerDay)
        .floor();
    return daysRemaining;
  }

  String displayDaysRemaining(Medication med) {
    return "You have ${calculateDaysRemaining(med)} day${calculateDaysRemaining(med) > 1 ? 's' : ''} before you run out.";
  }

  //builds
  @override
  Widget build(BuildContext context) {
    final hasMedication = widget.savedMedications.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('Medications')),
      body: hasMedication
          ? _buildUI()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No Medications saved yet!"),
                  if (canEditMedications) ...[
                    const Text("Add new Medication"),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
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
                                  const SnackBar(
                                    content: Text('Medication added!'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      label: const Text(""),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (canEditMedications) _createMedication(),
          _showMedications(),
        ],
      ),
    );
  }

  //widgets

  /* Needs Fixed -- 
  
*/
  Widget _showMedications() {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: widget.savedMedications.length,
      itemBuilder: (context, index) {
        final med = widget.savedMedications[index];

        final String unit = (med.medType.toLowerCase() == 'tablet')
            ? (med.dosage == 1 ? 'tablet' : 'tablets')
            : (med.medType.toLowerCase() == 'injection')
            ? (med.dosage == 1 ? 'injection' : 'injections')
            : 'ml';

        final int daysRemaining = calculateDaysRemaining(med);
        final int difference = (daysRemaining - med.reminderLevel).floor();
        final bool needsReorder = calculateReorderSuggestion(med);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "${med.name}: Taking ${med.dosage} $unit\n${med.frequency} time${med.frequency > 1 ? 's' : ''} per ${med.frequencyType} ",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                  displayDaysRemaining(med),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (canEditMedications)
                _editMedicationButton(context, med, index),

              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  needsReorder
                      ? "Reorder required"
                      : "Reorder in $difference days",
                  style: TextStyle(
                    color: needsReorder
                        ? Colors.redAccent
                        : const Color.fromARGB(255, 3, 116, 62),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
  final num dosage;
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
      'medication_type': medType,
      'dosage': dosage,
      'frequency': frequency,
      'frequency_type': frequencyType,
      'current_stock': numRemaining,
      'low_stock_alert': reminderLevel,
      'notes': null,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'],
      medType: map['medication_type'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      frequencyType: map['frequency_type'],
      numRemaining: map['current_stock'],
      reminderLevel: map['low_stock_alert'],
    );
  }

  void add(Medication newMed) {}
}
