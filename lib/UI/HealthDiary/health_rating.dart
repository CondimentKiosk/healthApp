import 'package:flutter/material.dart';
import 'package:health_app/UI/HealthDiary/symptom_selection.dart';
import 'package:intl/intl.dart';

class HealthDiaryPage extends StatefulWidget {
  final List<SymptomEntry> healthReport;
  final List<Symptom> symptoms;
  final Function(SymptomEntry) onSave;

  const HealthDiaryPage({
    super.key,
    required this.healthReport,
    required this.symptoms,
    required this.onSave,
  });

  @override
  State<HealthDiaryPage> createState() => _HealthDiaryPageState();
}

class _HealthDiaryPageState extends State<HealthDiaryPage> {
  final _formkey = GlobalKey<FormState>();
  final Map<String, double?> ratings = {};
  final Set<String> ignoredSymptoms = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final symptom in widget.symptoms) {
      ratings[symptom.name] = null;
    }
  }

  void toggleIgnore(String name, bool? value) {
    setState(() {
      if (value == true) {
        ignoredSymptoms.add(name);
      } else {
        ignoredSymptoms.remove(name);
      }
    });
  }

  void saveEntry() {
    final Map<String, int> finalRatings = {};

    for (final name in ratings.keys) {
      if (!ignoredSymptoms.contains(name) && ratings[name] != null) {
        finalRatings[name] = ratings[name]!.round();
      }
    }

    final entry = SymptomEntry(
      timeStamp: DateTime.now(),
      symptomRatings: finalRatings,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    print("Saving entry: ${entry.symptomRatings}");
    widget.onSave(entry);
    Navigator.pop(context);
  }

  Future<void> goToSymptomSelector() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SymptomSelectionPage(
          predefinedSymptoms: [
            Symptom(name: "Pain"),
            Symptom(name: "Fatigue"),
            Symptom(name: "Sleep Quality"),
            Symptom(name: "Mood"),
            Symptom(name: "Nausea"),
            Symptom(name: "Appetite"),
            Symptom(name: "Level of activeness"),
            Symptom(name: "Concentration"),
            Symptom(name: "Memory"),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      final updatedSymptomNames = result as List<String>;
      setState(() {
        widget.symptoms
          ..clear()
          ..addAll(updatedSymptomNames.map((name) => Symptom(name: name)));

        ratings.clear();
        for (final name in updatedSymptomNames) {
          ratings.putIfAbsent(name, () => 5.0); // defaults to 5
        }
        ratings.removeWhere((key, _) => !updatedSymptomNames.contains(key));
        ignoredSymptoms.removeWhere(
          (name) => !updatedSymptomNames.contains(name),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Diary")),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    final hasSymptoms = widget.symptoms.isNotEmpty;

    return Scaffold(
      body: hasSymptoms
          ? Form(
              key: _formkey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Manage Symptoms"),
                    onPressed: goToSymptomSelector,
                  ),
                  const SizedBox(height: 12),
                  ...widget.symptoms.map((sym) {
                    final name = sym.name;
                    final ignored = ignoredSymptoms.contains(name);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: ignored,
                              onChanged: (value) => toggleIgnore(name, value),
                            ),
                            const Text("Ignore This Time"),
                          ],
                        ),
                        Slider(
                          value: ratings[name] ?? 5.0,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: ratings[name]?.round().toString() ?? "?",
                          onChanged: ignored
                              ? null
                              : (value) {
                                  setState(() {
                                    ratings[name] = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  const Text("Notes (Optional) : "),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Any additional comments...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveEntry,
                    child: const Text("Save Entry"),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No tracked symptoms yet"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: goToSymptomSelector,
                    label: const Text("Select Symptoms"),
                  ),
                ],
              ),
            ),
    );
  }
}
// Widget _SymptomEntries(){

// }

class SymptomEntry {
  DateTime timeStamp;
  Map<String, int> symptomRatings;
  String? notes;

  SymptomEntry({
    required this.timeStamp,
    required this.symptomRatings,
    this.notes,
  });


Map<String, dynamic> toMap(){
  final date = DateFormat('yyyy-MM-dd').format(timeStamp);
final time = DateFormat('HH:mm:ss').format(timeStamp);
  return{
    'entry_date': date,
    'entry_time': time,
    'entry_notes': notes,
    'symptoms': symptomRatings
  };
}

factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    final date = map['entry_date'] as String;
    final time = map['entry_time'] as String;
    final dateTime = DateTime.parse('$date $time');

    return SymptomEntry(
      timeStamp: dateTime,
      symptomRatings: Map<String, int>.from(map['symptoms'] ?? {}),
      notes: map['entry_notes'],
    );
  }
}
class Symptom {
  final String name;
  final String? category;
  final String? desc;

  Symptom({required this.name, this.category, this.desc});
}
