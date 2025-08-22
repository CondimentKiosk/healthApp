import 'package:flutter/material.dart';
import 'package:health_app/UI/Appointments/edit_appointments_page.dart';
import 'package:health_app/UI/Appointments/manual_appointment_entry_page.dart';
import 'package:health_app/UI/Appointments/scanner_page.dart';
import 'package:health_app/Services/access_rights.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentsPage extends StatefulWidget {
  final List<Appointment> savedAppointments;

  const AppointmentsPage({super.key, required this.savedAppointments});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
      final canEditAppointments = AccessRights.has('appointment', 'edit');


  void _editAppointment(int index, Appointment updatedAppointment) {
    setState(() {
      widget.savedAppointments[index] = updatedAppointment;
    });
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
                    label: const Text("Add Appointment"),
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
        if (canEditAppointments) _createManualAppt(),
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
              if (canEditAppointments)
                _editAppointmentsButton(context, appt, index),
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
