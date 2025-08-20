import 'package:flutter/material.dart';
import 'package:health_app/Services/medication_service.dart';
import 'package:health_app/UI/Medication/create_medication_page.dart';
import 'package:health_app/UI/Medication/edit_medication_page.dart';
import 'package:health_app/access_rights.dart';

class MedicationPage extends StatefulWidget {
  final List<Medication> savedMedications;
  final int carerId;
  final int patientId;

  const MedicationPage({
    super.key,
    required this.savedMedications,
    required this.carerId,
    required this.patientId,
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
  final List<Medication> savedMedications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final meds = await MedicationService().getMedicationsByPatient();
      setState(() {
        savedMedications.clear();
        savedMedications.addAll(meds);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load medications: $e")));
    }
  }

  Future<void> _addMedication(Medication newMed) async {
  setState(() => savedMedications.add(newMed)); // optimistic update
  try {
    final savedMed = await MedicationService().createMedication(newMed);
    setState(() {
      final index = savedMedications.indexOf(newMed);
      if (index != -1) savedMedications[index] = savedMed;
    });
  } catch (e) {
    setState(() => savedMedications.remove(newMed)); // rollback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save medication: $e")),
    );
  }
}


  Future<void> _editMedication(int index, Medication updatedMed) async {
    final oldMed = savedMedications[index];
    setState(() => savedMedications[index] = updatedMed); // optimistic update

    try {
      await MedicationService().updateMedication(updatedMed.id!, updatedMed);
    } catch (e) {
      setState(() => savedMedications[index] = oldMed); // rollback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update medication: $e")),
      );
    }
  }

  Future<void> _deleteMedication(int index) async {
    final med = savedMedications[index];
    setState(() => savedMedications.removeAt(index)); // optimistic update

    try {
      await MedicationService().deleteMedication(med.id!);
    } catch (e) {
      setState(() => savedMedications.insert(index, med)); // rollback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete medication: $e")),
      );
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasMedication = savedMedications.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: hasMedication
          ? _buildUI()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No Medications saved yet!"),
                  if (canEditMedications) _createMedication(),
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
              if (canEditMedications)
                ElevatedButton(
                  onPressed: () => _deleteMedication(index),
                  child: const Text("Delete"),
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
                _addMedication(newMed);

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
  final int? id;
  final String name;
  final String medType;
  final num dosage;
  final int frequency;
  final String frequencyType;
  final int numRemaining;

  final num reminderLevel;

  Medication({
    this.id,
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
      'medication_id': id,
      'med_name': name,
      'medication_type': medType,
      'dosage': dosage,
      'times_per': frequency,
      'frequency_type': frequencyType,
      'current_stock': numRemaining,
      'low_stock_alert': reminderLevel,
      'notes': null,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['medication_id'],
      name: map['med_name'],
      medType: map['medication_type'],
      dosage: map['dosage'],
      frequency: map['times_per'],
      frequencyType: map['frequency_type'],
      numRemaining: map['current_stock'],
      reminderLevel: map['low_stock_alert'],
    );
  }

  void add(Medication newMed) {}
}
