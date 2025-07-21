import 'package:flutter/material.dart';

class HealthDiaryPage extends StatefulWidget {
  final List<SymptomEntry> healthReport;
  final List<Symptom> symptoms;

  const HealthDiaryPage({
    super.key,
    required this.healthReport,
    required this.symptoms,
  });

  @override
  State<HealthDiaryPage> createState() => _HealthDiaryPageState();
}

class _HealthDiaryPageState extends State<HealthDiaryPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class SymptomEntry {
  DateTime timeStamp;
  Map<String, int> symptomRatings;
  String? notes;

  SymptomEntry({
    required this.timeStamp,
    required this.symptomRatings,
    this.notes
  });
}

class Symptom {
  final String name;
  final String? category;
  final String? desc;

  Symptom({
    required this.name,
    this.category,
    this.desc
  });
}
