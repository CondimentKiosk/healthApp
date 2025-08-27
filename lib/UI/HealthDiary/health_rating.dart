import 'package:flutter/material.dart';
import 'package:health_app/Services/health_diary_services.dart';
import 'package:health_app/Services/symptom_services.dart';
import 'package:health_app/UI/HealthDiary/symptom_selection.dart';
import 'package:intl/intl.dart';

class HealthDiaryPage extends StatefulWidget {
  final List<SymptomEntry> healthReport;
  final List<Symptom> symptoms;
  final Function(SymptomEntry) onSave;
  final int patientId;
  final int userId;

  const HealthDiaryPage({
    super.key,
    required this.healthReport,
    required this.symptoms,
    required this.onSave,
    required this.patientId,
    required this.userId,
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

  void toggleIgnore(String name, bool? selected) {
    setState(() {
      if (selected == true) {
        ignoredSymptoms.add(name);
      } else {
        ignoredSymptoms.remove(name);
      }
    });
  }

  Future<void> saveEntry() async {
    final Map<String, int> finalRatings = {};

    for (final name in ratings.keys) {
      if (!ignoredSymptoms.contains(name) && ratings[name] != null) {
        finalRatings[name] = ratings[name]!.round();
      }
    }

    final entry = SymptomEntry(
      timeStamp: DateTime.now().toUtc(),
      symptomRatings: finalRatings,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
print("Raw timestamp: ${entry.timeStamp}");

    try {
      await saveHealthEntry(entry);

      widget.onSave(entry);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Diary entry saved!')));
        Navigator.pop(context, entry);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save entry: $e')));
      }
    }
  }

  Future<void> goToSymptomSelector() async {
    try {
      final symptoms = await getSymptoms(widget.patientId);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SymptomSelectionPage(
            userSymptoms: symptoms,
            patientId: widget.patientId,
            trackedSymptoms: widget.symptoms
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
    } catch (e) {
      print("Failed to load symptoms or navigate: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open symptom selector: $e")),
      );
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
  int? entry_id;
  DateTime timeStamp;
  Map<String, int> symptomRatings;
  String? notes;

  SymptomEntry({
    this.entry_id,
    required this.timeStamp,
    required this.symptomRatings,
    this.notes,
  });

  /// Convert to map for sending to backend
  Map<String, dynamic> toMap({bool includeId = false}) {
    // Store full UTC timestamp

    final symptomList = symptomRatings.entries
        .map((e) => {'symptom_name': e.key, 'rating': e.value})
        .toList();

    final map = {
  'entry_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(timeStamp.toLocal()),
      'entry_notes': notes,
      'symptoms': symptomList,
    };

    if (includeId && entry_id != null) {
      map['entry_id'] = entry_id;
    }

    return map;
  }

  /// Convert from map received from backend
factory SymptomEntry.fromMap(Map<String, dynamic> map) {
  final rawDateTime = map['entry_datetime'] as String?;

  late DateTime dateTime;
  if (rawDateTime == null || rawDateTime.isEmpty) {
    throw FormatException('entry_datetime is missing');
  } else {
    try {
      // Try parsing with microseconds first
      dateTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').parse(rawDateTime, true).toLocal();
    } catch (_) {
      // Fallback to seconds only
      dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(rawDateTime, true).toLocal();
    }
  }
  

  final symptomsList = map['symptoms'] as List<dynamic>? ?? [];

  return SymptomEntry(
    entry_id: map['entry_id'],
    timeStamp: dateTime,
    symptomRatings: {
      for (final e in symptomsList)
        e['symptom_name'] as String: e['rating'] as int,
    },
    notes: map['entry_notes'] as String?,
  );
}
}


class Symptom {
  final int? id;
  final String name;
  final bool? isPredefined;
  final int? patientId;

  Symptom({this.id, required this.name, this.isPredefined, this.patientId});

  Map<String, dynamic> toMap() {
    return {
      'symptom_id': id,
      'symptom_name': name,
      'is_predefined': isPredefined,
      'patient_id': patientId,
    };
  }

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['symptom_id'],
      name: map['symptom_name'],
      isPredefined: map['is_predefined'],
      patientId: map['patient_id'],
    );
  }
}
