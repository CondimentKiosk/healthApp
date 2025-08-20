import 'package:health_app/Services/globalAPIClient.dart';
import 'package:health_app/Services/user_service.dart';
import 'package:health_app/UI/Appointments/appointments_page.dart';
import 'package:flutter/material.dart';
import 'package:health_app/UI/HealthDiary/health_rating.dart';
import 'package:health_app/UI/HealthDiary/health_record.dart';
import 'package:health_app/UI/Login-Create/login_page.dart';
import 'package:health_app/UI/Login-Create/register_page.dart';
import 'package:health_app/UI/Medication/medication_page.dart';
import 'package:health_app/UI/no_access.dart';
import 'package:health_app/access_rights.dart';

import 'UI/Appointments/scanner_page.dart';

void main() {
  ApiClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 21, 92, 1),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 25),
          labelLarge: TextStyle(fontSize: 25),
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
  });
  final String title;
  final int userId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Appointment> savedAppointments = [];
  List<Medication> savedMedications = [];
  List<SymptomEntry> healthReport = [];
  List<Symptom> symptoms = [];
  int patientId = UserService.currentPatientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title}')),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24), // Outer padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _styledButton(_viewScanner()),
          const SizedBox(height: 20),
          _styledButton(_viewAppointments()),
          const SizedBox(height: 20),
          _styledButton(_viewMedication()),
          const SizedBox(height: 20),
          if (AccessRights.has('health_diary', 'edit'))
            _styledButton(_viewHealthDiary()),
          const SizedBox(height: 20),
          _styledButton(_viewHealthReport()),
          const SizedBox(height: 20),
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
      },
      child: const Text("Open Scanner"),
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
              builder: (_) =>
                  AppointmentsPage(savedAppointments: savedAppointments),
            ),
          );
        }
      },
      child: const Text('View Appointments'),
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
                patientId: patientId,
                carerId: widget.userId,
              ),
            ),
          );
        }
      },
      child: const Text("Open Medication"),
    );
  }

  Widget _viewHealthDiary() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthDiaryPage(
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
      },
      child: const Text("Open Health Diary"),
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
              builder: (context) =>
                  HealthRecordPage(healthReport: healthReport),
            ),
          );
        }
      },
      child: const Text("Open Health Report"),
    );
  }
}
