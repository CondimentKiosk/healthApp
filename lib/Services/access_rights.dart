import 'dart:convert';
import 'package:http/http.dart' as http;

class AccessRights {
  static int? userId;
  static int? patientId;
  static final Map<String, String> rights = {};

 static Future<void> loadFromMap(int uId, int pId, Map<String, dynamic> accessMap) async {
    userId = uId;
    patientId = pId;
    rights
      ..clear()
      ..addAll(accessMap.map((key, value) => MapEntry(key, value.toString().toLowerCase())));
  }
  
  static Future<void> load(dynamic uId, dynamic pId) async {

    userId = uId;
    patientId = pId;

    final url = Uri.parse(
      'http://192.168.0.28:4000/permissions/$uId/$patientId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      rights
        ..clear()
        ..addAll(data.map((key, value)=> MapEntry(key, value.toString().toLowerCase())));
    } else {
      throw Exception('Failed to load access rights: ${response.statusCode}');
    }
  }

  
  static bool has(String resource, String requiredLevel) {
    final current = rights[resource] ?? 'none';

    if (requiredLevel == 'none') return true;
    if (requiredLevel == 'read') {
      return current == 'read' || current == 'edit';
    }
    if (requiredLevel == 'edit') {
      return current == 'edit';
    }
    return false;
  }

  static String level(String resource) => rights[resource] ?? 'none';
}
