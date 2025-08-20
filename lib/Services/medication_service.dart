import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:health_app/Services/globalAPIClient.dart';
import 'package:http/http.dart' as http;
import '../UI/Medication/medication_page.dart';

class MedicationService {
  final Dio _dio;

  MedicationService([Dio? dio]) : _dio = dio ?? ApiClient.dio;

  Future<Medication> createMedication(Medication med) async {
  final medData = med.toMap(); // your payload

  try {
    final response = await _dio.post('/medications', data: medData);
    print('Response from API: ${response.data}'); // << see what the server is saying
    return Medication.fromMap(response.data);
  } on DioException catch (e) {
    print('Failed to save medication: ${e.response?.data ?? e.message}');
    rethrow; // optional: rethrow if you still want the caller to handle it
  }
}



  final String baseUrl = 'http://192.168.0.28:4000';


   Future<List<Medication>> getMedicationsByPatient() async {
    final response = await _dio.get(ApiClient.patientRoute(''));
    return (response.data as List)
        .map((json) => Medication.fromMap(json))
        .toList();
  }

   Future<void> updateMedication(int medicationId, Medication med) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$medicationId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(med.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update medication");
    }
  }

   Future<void> deleteMedication(int medicationId) async {
    final response = await http.delete(Uri.parse("$baseUrl/$medicationId"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete medication");
    }
  }
}
