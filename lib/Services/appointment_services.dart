import 'dart:convert';

import 'package:health_app/Services/access_rights.dart';
import 'package:health_app/UI/Appointments/scanner_page.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.0.28:4000/appointments';

final userId = AccessRights.userId;
final patientId = AccessRights.patientId;

Future<void> saveAppointment(Appointment apt) async {

  if (userId == null || patientId == null) {
  throw Exception('User ID or Patient ID not loaded');
}

final body = apt.toMap();
body['user_id'] = userId;        
body['patient_id'] = patientId; 

final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 201) {
    print('Appointment saved successfully');
  } else {
    throw Exception('Failed to save appointment: ${response.body}');
  }
}

Future<List<Appointment>> getAppointmentsForPatient(int? patientId) async {
  if (patientId == null) throw Exception('Patient ID not loaded');
  final url = Uri.parse('$baseUrl/$patientId'); 
  final response = await http.get(url);

  if (response.statusCode == 200) {

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Appointment.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load appointments: ${response.body}');
  }
}


Future<void> updateAppointment(Appointment apt) async {

if (userId == null || patientId == null) {
  throw Exception('User ID or Patient ID not loaded');
}

final body = apt.toMap(includeId: true);
body['user_id'] = userId;       
body['patient_id'] = patientId; 

  if (apt.appointment_id == null) {
    throw Exception('Appointment ID is required for update');
  }

  final response = await http.put(   
    Uri.parse('$baseUrl/${apt.appointment_id}'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
      print('Appointment updated successfully');
  } else {
      throw Exception('Failed to update appointment: ${response.body}');
  }
}

Future<void> deleteAppointment(Appointment apt) async {
  if (apt.appointment_id == null) {
    throw Exception('Appointment ID is required for delete');
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/${apt.appointment_id}'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Appointment deleted successfully');
  } else {
    throw Exception('Failed to delete appointment: ${response.body}');
  }
}



