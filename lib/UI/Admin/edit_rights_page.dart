import 'package:flutter/material.dart';
import 'package:health_app/Services/access_rights.dart';
import 'package:health_app/UI/Admin/admin_page.dart';

class EditRightsPage extends StatefulWidget {
  final int userId;
  final int patientId;
  final String userName;
  final List<UserPermission> resourceRights;

  const EditRightsPage({
    super.key,
    required this.userId,
    required this.patientId,
    required this.userName,
    required this.resourceRights,
  });

  @override
  State<EditRightsPage> createState() => _EditRightsPageState();
}

class _EditRightsPageState extends State<EditRightsPage> {
  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await AccessRights.load(
        widget.userId,
        widget.patientId,
      );
      setState(() {
        widget.resourceRights.clear();
        widget.resourceRights.addAll(permissions);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load permissions: $error')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Edit Rights for ${widget.userName}")),
    body: widget.resourceRights.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Permission levels:\n"
                  "'none' : no access to the corresponding page\n"
                  "'read' : can only read information, cannot create or edit information\n"
                  "'edit' : can create and edit information\n"
                  "'admin' : can control the permissions of other users",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.resourceRights.length,
                  itemBuilder: (context, index) {
                    final permission = widget.resourceRights[index];
                    return ListTile(
                      title: Text(permission.resource),
                      trailing: DropdownButton<String>(
                        value: permission.rights,
                        items: ["none", "read", "edit", "admin"]
                            .map(
                              (right) => DropdownMenuItem(
                                value: right,
                                child: Text(right),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              permission.rights = value; // update the same object
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _submitChanges,
      icon: const Icon(Icons.save),
      label: const Text("Save"),
    ),
  );
}


  Future<void> _submitChanges() async {
    try {
      await AccessRights.updatePermissions(
        widget.userId,
        widget.patientId,
        widget.resourceRights,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permissions updated successfully")),
      );
      Navigator.pop(context, true); // return to admin page
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update permissions: $error")),
      );
    }
  }
}
