import 'dart:convert';
import 'package:health_app/UI/Admin/admin_page.dart';
import 'package:http/http.dart' as http;

class AccessRights {
  static int? userId;
  static int? patientId;
  static final Map<String, String> rights = {};

  static Future<void> loadFromMap(
    int uId,
    int pId,
    Map<String, dynamic> accessMap,
  ) async {
    userId = uId;
    patientId = pId;
    rights
      ..clear()
      ..addAll(
        accessMap.map(
          (key, value) => MapEntry(key, value.toString().toLowerCase()),
        ),
      );
      print("Rights map: $rights");

  }

  static Future<List<UserPermission>> load(int uId, int pId) async {
    userId = uId;
    patientId = pId;

    final url = Uri.parse(
      'http://192.168.0.28:4000/permissions/access/$uId/$patientId',
    );

    final response = await http.get(url);
    print('HTTP response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final permissions = data.entries.map((entry) {
        return UserPermission(
          resource: entry.key,
          rights: entry.value.toString().toLowerCase(),
        );
      }).toList();

      return permissions;
    } else {
      throw Exception('Failed to load access rights: ${response.statusCode}');
    }
  }

  static bool has(String resource, String requiredLevel) {
    final current = rights[resource] ?? 'none';

    if (requiredLevel == 'none') return true;
    if (requiredLevel == 'read') {
      return current == 'read' || current == 'edit' || current == 'admin';
    }
    if (requiredLevel == 'edit') {
      return current == 'edit' || current == 'admin';
    }
    if (requiredLevel == 'admin') {
      return current == 'admin';
    }
    return false;
  }

  static String level(String resource) => rights[resource] ?? 'none';

  static Future<List<User>> loadUsersForPatient(int pId) async {
    patientId = pId;

    final url = Uri.parse(
      'http://192.168.0.28:4000/permissions/$patientId/allUsers',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
  final List<dynamic> rawUsers = body['users']; 

  final List<User> users = rawUsers.map((user) => User.fromMap(user)).toList();


      return users;
    } else {
      throw Exception('Failed to load access rights: ${response.statusCode}');
    }
  }

  static Future<void> updatePermissions(
    int userId,
    int patientId,
    List<UserPermission> rights,
  ) async {
    final url = Uri.parse(
      'http://192.168.0.28:4000/permissions/$userId/$patientId',
    );
    final body = jsonEncode(
    rights.map((r) => r.toMap()).toList(), 
  );

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update permissions");
    }
  }
}
