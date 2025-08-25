
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget{
  final List<String> users;
  final int patientId;
  final int userId;

const AdminPage({
    super.key,
    required this.users,
    required this.patientId,
    required this.userId,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
  
}

class _AdminPageState extends State<AdminPage>{


  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}