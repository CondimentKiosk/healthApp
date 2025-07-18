import 'package:health_app/Appointments/appointments_page.dart';
import 'package:flutter/material.dart';
import 'package:health_app/Medication/medication_page.dart';

import 'Appointments/scanner_page.dart';

void main() {
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
      initialRoute: '/',
      routes: {'/': (context) => const MyHomePage(title: 'Health Hub')},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Appointment> savedAppointments = [];
  List<Medication> savedMedications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AppointmentsPage(savedAppointments: savedAppointments),
          ),
        );
      },
      child: const Text("View Appointments"),
    );
  }

  // Widget _addMedication(){
  //   return ElevatedButton(
  //     onPressed: onPressed, child: child
  //     )
  // }

  Widget _viewMedication() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MedicationPage(savedMedications: savedMedications,)),
        );
      },
      child: const Text("Open Medication"),
    );
  }
}
