import 'dart:convert';

import 'package:health_app/UI/HealthDiary/health_rating.dart';
import 'package:http/http.dart' as http;

final String baseUrl =
    "http://192.168.0.28:4000/symptoms"; // replace with actual

Future<List<Symptom>> getSymptoms(int patientId) async {
  final response = await http.get(Uri.parse("$baseUrl/$patientId"));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (sym) => Symptom(
            id: sym['symptom_id'],
            name: sym['symptom_name'] ?? '',
            isPredefined: sym['is_predefined'] == 1,
            patientId: sym['patient_id'],
          ),
        )
        .toList();
  } else {
    throw Exception("Failed to load symptoms");
  }
}

Future<void> saveCustomSymptom(int patientId, String name) async {
  final response = await http.post(
    Uri.parse("$baseUrl"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"patient_id": patientId, "name": name}),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to save symptom");
  }
}
