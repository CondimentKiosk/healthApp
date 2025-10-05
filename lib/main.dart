import 'package:flutter/cupertino.dart';
import 'package:health_app/UI/Admin/admin_page.dart';
import 'package:health_app/UI/Appointments/appointments_page.dart';
import 'package:flutter/material.dart';
import 'package:health_app/UI/HealthDiary/health_rating.dart';
import 'package:health_app/UI/HealthDiary/health_record.dart';
import 'package:health_app/UI/LoginCreate/login_page.dart';
import 'package:health_app/UI/LoginCreate/register_page.dart';
import 'package:health_app/UI/Medication/medication_page.dart';
import 'package:health_app/UI/no_access.dart';
import 'package:health_app/Services/access_rights.dart';

import 'UI/Appointments/scanner_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 56, 10),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 25),
          titleMedium: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 243, 2, 2),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.userId,
    required this.role,
  });
  final String title;
  final int userId;
  final String role;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Appointment> savedAppointments = [];
  List<Medication> savedMedications = [];
  List<SymptomEntry> healthReport = [];
  List<Symptom> symptoms = [];
  List<User> users = [];
  List<UserPermission> resourceRights = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title}')),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Appointments Section ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Appointments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _styledButton(_viewAppointments()),
                  Padding(padding: const EdgeInsets.all(10)),
                  const SizedBox(height: 12),
                  _styledButton(_viewScanner()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Medication Section ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Medication",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _styledButton(_viewMedication()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Health Diary Section ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Health Tracking",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _styledButton(_viewHealthDiary()),
                    Padding(padding: const EdgeInsets.all(10)),
                    const SizedBox(height: 12),
                    _styledButton(_viewHealthReport()),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // --- Admin Section ---
          if (AccessRights.has('admin', 'admin'))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _styledButton(_viewAdminPage()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _styledButton(Widget button) {
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _viewScanner() {
    return ElevatedButton(
      onPressed: () {
        if (!AccessRights.has('appointment', 'edit')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoAccessPage(resourceName: 'Letter Scanner'),
            ),
          );
        } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerPage(
              savedAppointments: savedAppointments,
              onSaveAppointment: (newAppt) {
                setState(() {
                  savedAppointments.add(newAppt);
                });
              },
            ),
          ),
        );
      }
      },
      child: const Text("Scan Appointment Letter"),
    );
  }

  Widget _viewAppointments() {
    return ElevatedButton(
      onPressed: () {
        if (!AccessRights.has('appointment', 'read')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoAccessPage(resourceName: 'Appointments'),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentsPage(
                savedAppointments: savedAppointments,
                patientId: AccessRights.patientId!,
                userId: AccessRights.userId!,
              ),
            ),
          );
        }
      },
      child: const Text('View All Appointments'),
    );
  }

  Widget _viewMedication() {
    return ElevatedButton(
      onPressed: () {
        if (!AccessRights.has('medication', 'read')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoAccessPage(resourceName: 'Medications'),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationPage(
                savedMedications: savedMedications,
                userId: AccessRights.userId!,
                patientId: AccessRights.patientId!,
              ),
            ),
          );
        }
      },
      child: const Text("View All Medications"),
    );
  }

  Widget _viewHealthDiary() {
    return ElevatedButton(
      onPressed: () {
        if (!AccessRights.has('health_diary', 'edit')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoAccessPage(resourceName: 'Health Tracking'),
            ),
          );
        } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthDiaryPage(
              patientId: AccessRights.patientId!,
              userId: AccessRights.userId!,
              healthReport: healthReport,
              symptoms: symptoms,
              onSave: (SymptomEntry entry) {
                setState(() {
                  healthReport.add(entry);
                });
              },
            ),
          ),
        );
      }
      },
      child: const Text("Track Your Symptoms"),
    );
  }

  Widget _viewHealthReport() {
    return ElevatedButton(
      onPressed: () {
        if (!AccessRights.has('health_diary', 'read')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoAccessPage(resourceName: 'Health Report'),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthRecordPage(
                patientId: AccessRights.patientId!,
                userId: AccessRights.userId!,
                healthReport: healthReport,
              ),
            ),
          );
        }
      },
      child: const Text("View Your Health Report"),
    );
  }

  Widget _viewAdminPage() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(
              patientId: AccessRights.patientId!,
              userId: AccessRights.userId!,
              users: users,
              resourceRights: resourceRights,
            ),
          ),
        );
      },
      child: const Text("View Admin Controls"),
    );
  }
}
