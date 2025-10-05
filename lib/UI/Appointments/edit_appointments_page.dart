import 'package:flutter/material.dart';
import 'package:health_app/Services/appointment_services.dart';
import 'package:health_app/UI/Appointments/appointments_page.dart';
import 'package:intl/intl.dart';

class EditAppointmentsPage extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentsPage({super.key, required this.appointment});

  @override
  State<EditAppointmentsPage> createState() => _EditAppointmentsPageState();
}

class _EditAppointmentsPageState extends State<EditAppointmentsPage> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _consultantController;
  late TextEditingController _hospitalController;
  late TextEditingController _notesController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.appointment.date),
    );

    _timeController = TextEditingController(text: widget.appointment.time);
    _consultantController = TextEditingController(
      text: widget.appointment.consultant,
    );
    _hospitalController = TextEditingController(
      text: widget.appointment.hospital,
    );
    _notesController = TextEditingController(text: widget.appointment.notes);
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      final updatedAppt = Appointment(
        appointment_id: widget.appointment.appointment_id,
        date: parsedDate,
        time: _timeController.text,
        consultant: _consultantController.text.toLowerCase(),
        hospital: _hospitalController.text.toLowerCase(),
        notes: _notesController.text,
      );

      updateAppointment(updatedAppt)
          .then((_) {
            Navigator.pop(context, updatedAppt);
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update appointment: $error")),
            );
          });
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}"
            "/${picked.year}";
      });
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      final formatted = picked.format(context);
      setState(() {
        _timeController.text = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                validator: (value) => value!.isEmpty ? 'Enter a date' : null,
                onTap: selectDate,
              ),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Time'),
                validator: (value) => value!.isEmpty ? 'Enter a time' : null,
                onTap: selectTime,
              ),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a hospital' : null,
              ),
              TextFormField(
                controller: _consultantController,
                decoration: const InputDecoration(labelText: 'Consultant or Department'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a doctor or department' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
