import 'dart:convert';
import 'package:health_app/Services/access_rights.dart';
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


    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);

        final int userId = data['user_id'];
        final int patientId = data['patient_id'];

        if (data.containsKey('access')) await AccessRights.loadFromMap(userId, patientId, data['access']);
        

        return {
          'user_id': userId,
          'role': data['role'],
          'patient_id': patientId,
        };
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }
}
