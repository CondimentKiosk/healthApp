import 'package:flutter/material.dart';
import 'package:health_app/Services/appointment_services.dart'
    as AppointmentService;
import 'package:health_app/UI/Appointments/edit_appointments_page.dart';
import 'package:health_app/UI/Appointments/manual_appointment_entry_page.dart';
import 'package:health_app/UI/Appointments/scanner_page.dart';
import 'package:health_app/Services/access_rights.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentsPage extends StatefulWidget {
  final List<Appointment> savedAppointments;
  final int patientId;
  final int userId;

  const AppointmentsPage({
    super.key,
    required this.savedAppointments,
    required this.patientId,
    required this.userId,
  });

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final canEditAppointments = AccessRights.has('appointment', 'edit');

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appts = await AppointmentService.getAppointmentsForPatient(
        widget.patientId,
      );
      setState(() {
        widget.savedAppointments.clear();
        widget.savedAppointments.addAll(appts);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load Appointments : $e")),
      );
    }
  }

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  DateTime normaliseDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Map<DateTime, List<Appointment>> appointmentsByDate(
    List<Appointment> appointments,
  ) {
    final Map<DateTime, List<Appointment>> grouped = {};

    for (final appt in appointments) {
      final dateKey = normaliseDate(appt.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(appt);
    }

    return grouped;
  }

  bool isCalendarView = true;

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
                  if (canEditAppointments) ...[
                    const Text("Add new Appointment"),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final newAppt = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualAppointmentEntry(),
                          ),
                        );

                        if (newAppt != null && newAppt is Appointment) {
                          setState(() {
                            widget.savedAppointments.add(newAppt);
                          });
                        }
                      },
                      label: const Text("Add Appointments"),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget buildUI() {
    return Column(
      children: [
        if (canEditAppointments) _createAppointment(),
        ToggleButtons(
          isSelected: [isCalendarView, !isCalendarView],
          onPressed: (index) {
            setState(() {
              isCalendarView = index == 0;
            });
          },
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text("Calendar")),
            Padding(padding: EdgeInsets.all(8), child: Text("List")),
          ],
        ),
        Expanded(child: isCalendarView ? _calendarView() : _listView()),
      ],
    );
  }

  Widget _editAppointmentsButton(Appointment appt, int index) {
    return ElevatedButton(
      onPressed: () async {
        final updatedAppt = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditAppointmentsPage(appointment: appt),
          ),
        );

        if (updatedAppt != null && updatedAppt is Appointment) {
          setState(() {
            widget.savedAppointments[index] = updatedAppt;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Appointment Updated")));
        }
      },
      child: const Text('Edit'),
    );
  }

  Widget _createAppointment() {
    return ElevatedButton(
      onPressed: () async {
        try {
          final newAppt = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManualAppointmentEntry()),
          );

          if (newAppt != null && newAppt is Appointment) {
            setState(() {
              widget.savedAppointments.add(newAppt);
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to edit medication: $e")),
          );
        }
      },
      child: const Text("Add Appointments"),
    );
  }

  Widget _deleteAppointmentButton(Appointment appt, int index) {
  return ElevatedButton(
    onPressed: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text("Are you sure you want to delete this appointment?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // cancel
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), // confirm
                child: const Text("Delete"),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        try {
          await AppointmentService.deleteAppointment(appt);
          setState(() {
            widget.savedAppointments.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Appointment Deleted!")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete appointment: $e")),
          );
        }
      }
    },
    child: Text("Delete Appointment", style: Theme.of(context).textTheme.titleMedium),
  );
}

  Widget _listView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.savedAppointments.length,
      itemBuilder: (context, index) {
        final appt = widget.savedAppointments[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "${DateFormat('dd/MM/yy').format(appt.date)} at ${appt.time}",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                  "Consultant: ${appt.consultant} at ${appt.hospital}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (canEditAppointments) _editAppointmentsButton(appt, index),
              if (canEditAppointments) _deleteAppointmentButton(appt, index),
            ],
          ),
        );
      },
    );
  }

  Widget _calendarView() {
    final appts = appointmentsByDate(widget.savedAppointments);

    return Column(
      children: [
        TableCalendar(
          focusedDay: focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: (day, focus) {
            setState(() {
              selectedDay = day;
              focusedDay = focus;
            });
          },
          eventLoader: (day) {
            final dateKey = normaliseDate(day);
            return appts[dateKey] ?? [];
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children:
                (selectedDay == null
                        ? []
                        : appts[normaliseDate(selectedDay!)] ?? [])
                    .map(
                      (appt) => ListTile(
                        title: Text(
                          "${DateFormat('dd/MM/yyyy').format(appt.date)} at ${appt.time}",
                        ),
                        subtitle: Text(
                          "Consultant: ${appt.consultant} at ${appt.hospital}",
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}
