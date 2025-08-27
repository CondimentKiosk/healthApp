import 'package:flutter/material.dart';
import 'package:health_app/Services/symptom_services.dart';
import 'package:health_app/UI/HealthDiary/health_rating.dart';

class SymptomSelectionPage extends StatefulWidget {
  final List<Symptom> userSymptoms;
  final int patientId;
  final List<Symptom> trackedSymptoms;

  const SymptomSelectionPage({
    super.key,
    required this.userSymptoms,
    required this.patientId,
    required this.trackedSymptoms,
  });

  @override
  State<SymptomSelectionPage> createState() => _SymptomSelectionPageState();
}

class _SymptomSelectionPageState extends State<SymptomSelectionPage> {
  List<String> selectedSymptomNames = [];
  List<String> customSymptoms = [];
  final TextEditingController _symptomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedSymptomNames = widget.trackedSymptoms
        .map((sym) => sym.name)
        .toList();
  }

  Future<void> saveSymptoms() async {
    final selected = widget.userSymptoms
        .map((sym) => sym.name)
        .where((name) => selectedSymptomNames.contains(name))
        .toList();

    Navigator.pop(context, selected);
  }

  Future<void> addCustomSymptom() async {
    String name = _symptomNameController.text.trim();
    String lowerName = name.toLowerCase();
    if (name.isEmpty) return;

    bool alreadyExists = [
      ...widget.userSymptoms.map((sym) => sym.name),
      ...customSymptoms,
    ].any((sym) => sym.toLowerCase() == lowerName);

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Symptom '$name' already tracked")),
      );
      return;
    }
    final capitalised = capitalise(name);
    try {
      await saveCustomSymptom(widget.patientId, capitalised);

      setState(() {
        widget.userSymptoms.add(
          Symptom(name: capitalised, patientId: widget.patientId),
        );
        selectedSymptomNames.add(capitalised);
        customSymptoms.add(capitalised);
      });

      _symptomNameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save symptom: $e")));
    }
  }

  String capitalise(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final predefined = widget.userSymptoms.map((sym) => sym.name).toSet();
    final allSymptoms = {
      ...predefined,
      ...customSymptoms,
      ...selectedSymptomNames,
    }.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text("Select Symptoms")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: allSymptoms.map((name) {
                return CheckboxListTile(
                  title: Text(name),
                  value: selectedSymptomNames.contains(name),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedSymptomNames.add(name);
                      } else {
                        selectedSymptomNames.remove(name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _symptomNameController,
                    decoration: const InputDecoration(
                      hintText: "Add a new symptom",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addCustomSymptom,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveSymptoms,
            child: const Text("Save Symptoms For Tracking"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
