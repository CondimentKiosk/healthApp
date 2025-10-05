import 'package:flutter/material.dart';
import 'package:health_app/Services/appointment_services.dart'
    as AppointmentService;
import 'package:health_app/UI/Appointments/edit_appointments_page.dart';
import 'package:health_app/UI/Appointments/manual_appointment_entry_page.dart';
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
    loadAppointments();
  }

  Future<void> loadAppointments() async {
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

  DateTime appointmentDateTime(Appointment appt) {
    // appt.date is a DateTime (usually with midnight time)
    final date = appt.date;

    // If time is like "14:30"
    final parts = appt.time.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return DateTime(date.year, date.month, date.day, h, m);
    }

    // Fallback: just return the date at midnight
    return DateTime(date.year, date.month, date.day);
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
            final i = widget.savedAppointments.indexWhere(
              (a) => a.appointment_id == appt.appointment_id,
            );
            if (i != -1) {
              widget.savedAppointments[i] = updatedAppt;
            }
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
              content: const Text(
                "Are you sure you want to delete this appointment?",
              ),
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
              widget.savedAppointments.removeWhere(
                (a) => a.appointment_id == appt.appointment_id,
              );
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
      child: Text(
        "Delete Appointment",
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _listView() {
    final now = DateTime.now();

    final upcoming =
        widget.savedAppointments
            .where((appt) => appointmentDateTime(appt).isAfter(now))
            .toList()
          ..sort(
            (a, b) => appointmentDateTime(a).compareTo(appointmentDateTime(b)),
          );

    final past =
        widget.savedAppointments
            .where((appt) => appointmentDateTime(appt).isBefore(now))
            .toList()
          ..sort(
            (a, b) => appointmentDateTime(b).compareTo(appointmentDateTime(a)),
          );

    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Upcoming Appointments",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...upcoming.map(
            (appt) => _appointmentCard(
              appt,
              upcoming.indexOf(appt),
              ValueKey(appt.appointment_id),
            ),
          ),
        ],
        if (past.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Past Appointments",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...past.map(
            (appt) => _appointmentCard(
              appt,
              past.indexOf(appt),
              ValueKey(appt.appointment_id),
            ),
          ),
        ],
      ],
    );
  }

  Widget _appointmentCard(appt, int index, Key? key) {
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "${DateFormat('dd/MM/yy').format(appt.date)} at ${appt.time}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              "Consultant/Department: ${appt.consultant}"
              "\nHospital: ${appt.hospital}"
              "${appt.notes != null && appt.notes!.isNotEmpty ? "\nNotes: ${appt.notes}" : ""}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (canEditAppointments) _editAppointmentsButton(appt, index),
          if (canEditAppointments) _deleteAppointmentButton(appt, index),
        ],
      ),
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
                          "Consultant: ${appt.consultant} at ${appt.hospital}"
                          "\nNotes: ${appt.notes}",
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

class Appointment {
  final int? appointment_id;
  final DateTime date;
  final String time;
  final String consultant;
  final String hospital;
  final String? notes;
  final String? imagePath;

  Appointment({
    this.appointment_id,
    required this.date,
    required this.time,
    required this.consultant,
    required this.hospital,
    this.notes,
    this.imagePath,
  });

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'apt_description': null,
      'date': date.toString().split(' ')[0],
      'time': time,
      'doctor': consultant,
      'category_id': null,
      'location': hospital,
      'apt_notes': notes,
      'image_path': imagePath,
      'is_bookmarked': 0,
    };

    if (includeId && appointment_id != null) {
      map['appointment_id'] = appointment_id;
    }

    return map;
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointment_id: map['appointment_id'],
      date: map['date'] != null && map['date'].toString().isNotEmpty
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      time: map['time']?.toString() ?? "",
      consultant: map['doctor'],
      hospital: map['location'],
      notes: map['apt_notes'],
      imagePath: map['image_path']?.toString(),
    );
  }
  void add(Appointment newAppt) {}
}
