import 'dart:convert';

import 'package:health_app/Services/access_rights.dart';
import 'package:health_app/UI/Medication/medication_page.dart';
import 'package:http/http.dart' as http;

   const String baseUrl = 'http://192.168.0.28:4000/medications';

final userId = AccessRights.userId;
final patientId = AccessRights.patientId;

Future<void> saveMedication(Medication med) async {

if (userId == null || patientId == null) {
  throw Exception('User ID or Patient ID not loaded');
}

final body = med.toMap();
body['user_id'] = userId;        
body['patient_id'] = patientId;  


  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 201) {
    print('Medication saved successfully');
  } else {
    throw Exception('Failed to save medication: ${response.body}');
  }
}

 Future<List<Medication>> getMedicationsForPatient(int? patientId) async {
  if (patientId == null) throw Exception('Patient ID not loaded');

  final url = Uri.parse('$baseUrl/$patientId'); 
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Medication.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load medications: ${response.body}');
  }
}

Future<void> updateMedication(Medication med) async {

if (userId == null || patientId == null) {
  throw Exception('User ID or Patient ID not loaded');
}

final body = med.toMap(includeId: true);
body['user_id'] = userId;       
body['patient_id'] = patientId; 

  if (med.medication_id == null) {
    throw Exception('Medication ID is required for update');
  }

  final response = await http.put(   
    Uri.parse('$baseUrl/${med.medication_id}'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
      print('Medication updated successfully');
  } else {
      throw Exception('Failed to update medication: ${response.body}');
  }
}

Future<void> deleteMedication(Medication med) async {
  if (med.medication_id == null) {
    throw Exception('Medication ID is required for delete');
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/${med.medication_id}'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Medication deleted successfully');
  } else {
    throw Exception('Failed to delete medication: ${response.body}');
  }
}


