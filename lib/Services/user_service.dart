import 'dart:convert';
import 'package:health_app/Services/access_rights.dart';
import 'package:health_app/utils.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'http://192.168.0.28:4000';

  Future<int> registerUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['user_id'];
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    // Log the raw response to file
    await Logger.log('RAW LOGIN RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        await Logger.log('PARSED LOGIN RESPONSE: $data');

        final int userId = data['user_id'];
        final int patientId = data['patient_id'];

        // Use access rights from the login response directly
        if (data.containsKey('access')) {
          await AccessRights.loadFromMap(userId, patientId, data['access']);
          await Logger.log('ACCESS RIGHTS LOADED: ${data['access']}');
        } else {
          await Logger.log('NO ACCESS RIGHTS FOUND IN RESPONSE');
        }

        return {
          'user_id': userId,
          'role': data['role'],
          'patient_id': patientId,
        };
      } catch (e, stack) {
        await Logger.log('JSON DECODE ERROR: $e\n$stack');
        rethrow;
      }
    } else {
      await Logger.log('LOGIN FAILED STATUS: ${response.statusCode}');
      await Logger.log('LOGIN FAILED BODY: ${response.body}');
      throw Exception('Login failed: ${response.body}');
    }
  }
}
