import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:health_app/Services/globalAPIClient.dart';
import 'package:http/http.dart' as http;


class UserService {
  final String baseUrl = 'http://192.168.0.28:4000';

  static int currentUserId = 0;
  static int currentPatientId = 0;

  final Dio _dio;

  UserService([Dio? dio]) : _dio = dio ?? ApiClient.dio;

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
    final response = await _dio.post(
      '/users/login',
      data: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final userId = int.tryParse(data['user'].toString());
      final patientId = int.tryParse(data['patient_id'].toString());
      final role = data['role'].toString();

      if (userId == null || patientId == null) {
        throw Exception('Invalid login response: $data');
      }

      currentUserId = userId;
      currentPatientId = patientId;

      return {
        'user_id': userId,
        'role': role,
        'patient_id': patientId,
      };
    } else {
      throw Exception('Login failed: ${response.data}');
    }
  }

}
