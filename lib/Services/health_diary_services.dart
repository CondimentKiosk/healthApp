import 'dart:convert';

import 'package:health_app/Services/access_rights.dart';
import 'package:health_app/UI/HealthDiary/health_rating.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.0.28:4000/health';

final userId = AccessRights.userId;
final patientId = AccessRights.patientId;

Future<void> saveHealthEntry(SymptomEntry sym) async {
  if (userId == null || patientId == null) {
    throw Exception('User ID or Patient ID not loaded');
  }
  final body = sym.toMap();
  body['user_id'] = userId;
  body['patient_id'] = patientId;


  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 201) {
    print('Health Entry saved successfully');
  } else {
    throw Exception('Failed to save entry: ${response.body}');
  }
}

 Future<List<SymptomEntry>> getHealthReport(int? patientId) async {
  if (patientId == null) throw Exception('Patient ID not loaded');

  final url = Uri.parse('$baseUrl/$patientId'); 
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => SymptomEntry.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load health report: ${response.body}');
  }
}

Future<void> deleteHealthEntry(SymptomEntry entry) async {
  if (entry.entry_id == null) {
    throw Exception('Entry ID is required for delete');
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/${entry.entry_id}'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Entry deleted successfully');
  } else {
    throw Exception('Failed to delete entry: ${response.body}');
  }
}

