import 'package:flutter/material.dart';
import 'package:health_app/Services/medication_services.dart'
    as MedicationService;
import 'package:health_app/UI/Medication/create_medication_page.dart';
import 'package:health_app/UI/Medication/edit_medication_page.dart';
import 'package:health_app/Services/access_rights.dart';

class MedicationPage extends StatefulWidget {
  final List<Medication> savedMedications;
  final int patientId;
  final int userId;

  const MedicationPage({
    super.key,
    required this.savedMedications,
    required this.patientId,
    required this.userId,
  });

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

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final meds = await MedicationService.getMedicationsForPatient(
        widget.patientId,
      );
      setState(() {
        widget.savedMedications.clear();
        widget.savedMedications.addAll(meds);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load medications: $e')));
    }
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
                      onPressed: () async {
                        final newMed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateMedication(),
                          ),
                        );

                        if (newMed != null && newMed is Medication) {
                          setState(() {
                            widget.savedMedications.add(newMed);
                          });
                        }
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
  if (widget.savedMedications.isEmpty) {
    return const Center(child: Text("No medications saved yet."));
  }

  return Column(
    children: widget.savedMedications.map((med) {
      final String unit = (med.medType.toLowerCase() == 'tablet')
          ? (med.dosage == 1 ? 'tablet' : 'tablets')
          : (med.medType.toLowerCase() == 'injection')
              ? (med.dosage == 1 ? 'injection' : 'injections')
              : 'ml';

      final int daysRemaining = calculateDaysRemaining(med);
      final int difference = (daysRemaining - med.reminderLevel).floor();
      final bool needsReorder = calculateReorderSuggestion(med);

      final index = widget.savedMedications.indexOf(med);

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "${med.name}: Taking ${med.dosage} $unit\n"
                "${med.frequency} time${med.frequency > 1 ? 's' : ''} per ${med.frequencyType}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Text(
                displayDaysRemaining(med),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (canEditMedications) _editMedicationButton(med, index),
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
            if (canEditMedications) _deleteMedicationButton(med, index),
          ],
        ),
      );
    }).toList(),
  );
}

  Widget _createMedication() {
    return ElevatedButton(
      onPressed: () async {
        final newMed = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateMedication()),
        );

        if (newMed != null && newMed is Medication) {
          setState(() {
            widget.savedMedications.add(newMed);
          });
        }
      },
      child: const Text("Add Medication"),
    );
  }

  Widget _editMedicationButton(
    Medication med,
    int index,
  ) {
    return ElevatedButton(
      onPressed: () async {
        try{
        final updatedMed = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMedicationPage(medication: med),
          ),
        );

        if (updatedMed != null && updatedMed is Medication) {
          setState(() {
            widget.savedMedications[index] = updatedMed;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Medication Updated!")));
        }
        }catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to edit medication: $e")),
          );
        }
      },
      child: const Text("Edit"),
    );
  }

  Widget _deleteMedicationButton(Medication med, int index) {
    return ElevatedButton(
    onPressed: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text("Are you sure you want to delete this medication?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // cancel
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), // confirm
                child: const Text("Delete"),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        try {
          await MedicationService.deleteMedication(med);
          setState(() {
            widget.savedMedications.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Medication Deleted!")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete medication: $e")),
          );
        }
      }
    },
    child: Text("Delete Medication", style: Theme.of(context).textTheme.titleMedium),
  );
  }
}

//classes
class Medication {
  final int? medication_id;
  final String name;
  final String medType;
  final num dosage;
  final int frequency;
  final String frequencyType;
  final int numRemaining;
  final String? notes;

  final num reminderLevel;

  Medication({
    this.medication_id,
    required this.name,
    required this.medType,
    required this.dosage,
    required this.frequency,
    required this.frequencyType,
    required this.numRemaining,
    required this.reminderLevel,
    this.notes,
  });

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'med_name': name,
      'medication_type': medType,
      'dosage': dosage,
      'times_per': frequency,
      'frequency_type': frequencyType,
      'current_stock': numRemaining,
      'low_stock_alert': reminderLevel,
      'notes': notes,
    };

    if (includeId && medication_id != null) {
      map['medication_id'] = medication_id;
    }

    return map;
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      medication_id: map['medication_id'],
      name: map['med_name'] ?? '',
      medType: map['medication_type'] ?? '',
      dosage: map['dosage'] ?? 0,
      frequency: map['frequency'] ?? 1,
      frequencyType: map['frequency_type'] ?? '',
      numRemaining: map['current_stock'] ?? 0,
      reminderLevel: map['low_stock_alert'] ?? 0,
      notes: map[null],
    );
  }

  void add(Medication newMed) {}
}
