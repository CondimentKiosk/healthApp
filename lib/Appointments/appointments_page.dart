import 'package:flutter/material.dart';
import 'package:health_app/Appointments/edit_appointments_page.dart';
import 'package:health_app/Appointments/manual_appointment_entry_page.dart';
import 'package:health_app/Appointments/scanner_page.dart';

class AppointmentsPage extends StatefulWidget {
  final List<Appointment> savedAppointments;

  const AppointmentsPage({super.key, required this.savedAppointments});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  void _editAppointment(int index, Appointment updatedAppointment) {
    setState(() {
      widget.savedAppointments[index] = updatedAppointment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAppointments = widget.savedAppointments.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Saved Appointments"),
      ),
      body: hasAppointments
          ? buildUI()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No Appointments saved yet!"),
                  const Text("Add new Appointment"),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualAppointmentEntry(
                            appointments: widget.savedAppointments,
                            onSave: (newAppt) {
                              setState(() {
                                widget.savedAppointments.add(newAppt);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Appointment added!'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    label: const Text(""),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildUI() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _createManualAppt(),
        ...widget.savedAppointments.asMap().entries.map((entry) {
          final index = entry.key;
          final appt = entry.value;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "${appt.formattedDate} at ${appt.time}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  subtitle: Text(
                    "Consultant: ${appt.consultant} at ${appt.hospital}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                _editAppointmentsButton(context, appt, index),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _editAppointmentsButton(
    BuildContext context,
    Appointment appt,
    int index,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditAppointmentsPage(
              appointment: appt,
              onSave: (updatedAppt) => _editAppointment(index, updatedAppt),
            ),
          ),
        );
      },
      child: const Text('Edit'),
    );
  }

  Widget _createManualAppt() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManualAppointmentEntry(
              appointments: widget.savedAppointments,
              onSave: (newAppt) {
                setState(() {
                  widget.savedAppointments.add(newAppt);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment added!')),
                );
              },
            ),
          ),
        );
      },
      child: const Text("Add Appointment"),
    );
  }
}
