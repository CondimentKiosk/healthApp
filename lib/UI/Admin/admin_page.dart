import 'package:flutter/material.dart';
import 'package:health_app/Services/access_rights.dart';
import 'package:health_app/UI/Admin/edit_rights_page.dart';

class AdminPage extends StatefulWidget {
  final List<User> users;
  final int patientId;
  final int userId;
  final List<UserPermission> resourceRights;

  const AdminPage({
    super.key,
    required this.users,
    required this.patientId,
    required this.userId,
    required this.resourceRights,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await AccessRights.loadUsersForPatient(widget.patientId);
      setState(() {
        widget.users.clear();
        widget.users.addAll(users);
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUsers = widget.users.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text("Linked Users")),
      body: hasUsers
          ? _buildUI()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [const Text("No linked users")],
              ),
            ),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(child: Column(children: [_showAllUsers()]));
  }

  Widget _showAllUsers() {
    if (widget.users.isEmpty) {
      return Center(child: Text("No users linked to your account yet"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final user = widget.users[index];
        String userFullName = "${user.firstName} ${user.lastName}";

        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "User's Name:",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                  "$userFullName ID : ${user.id}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _editUserRights(user, index),
            ],
          ),
        );
      },
    );
  }

  Widget _editUserRights(User user, int index) {
    return ElevatedButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditRightsPage(
              userId: user.id!,
              patientId: widget.patientId,
              userName: user.firstName + user.lastName,
              resourceRights: [],
            ),
          ),
        );
      },
      child: const Text("Edit User Rights"),
    );
  }
}

class User {
  final int? id;
  final String firstName;
  final String lastName;

  User({this.id, required this.firstName, required this.lastName});

  Map<String, dynamic> toMap() {
    final map = {'user_id': id, 'first_name': firstName, 'last_name': lastName};
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['user_id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
    );
  }
}

class UserPermission {
  final String resource;
  String rights;

  UserPermission({required this.resource, required this.rights});

  Map<String, dynamic> toMap() {
    final map = {'resource_name': resource, 'level_name': rights};
    return map;
  }

  factory UserPermission.fromMap(Map<String, dynamic> map) {
    return UserPermission(
      resource: map['resource_name'],
      rights: map['level_name'],
    );
  }
}
