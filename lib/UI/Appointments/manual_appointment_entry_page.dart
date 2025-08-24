import 'package:flutter/material.dart';
import 'package:health_app/Services/appointment_services.dart';
import 'package:health_app/UI/Appointments/scanner_page.dart';
import 'package:intl/intl.dart';

class ManualAppointmentEntry extends StatefulWidget {
  const ManualAppointmentEntry({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManualAppointmentEntryState createState() => _ManualAppointmentEntryState();
}

class _ManualAppointmentEntryState extends State<ManualAppointmentEntry> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _consultantController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();

  void submitForm() {
    if (_formkey.currentState!.validate()) {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      final newAppt = Appointment(
        date: parsedDate,
        time: _timeController.text,
        consultant: _consultantController.text.isNotEmpty
            ? _consultantController.text
            : 'N/A',
        hospital: _hospitalController.text.isNotEmpty
            ? _hospitalController.text
            : 'N/A',
      );

      saveAppointment(newAppt)
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment added manually!')),
            );
            _dateController.clear();
            _timeController.clear();
            _consultantController.clear();
            _hospitalController.clear();

            Navigator.pop(context, newAppt);
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add medication $error')),
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
      appBar: AppBar(title: Text('Manual Appointment Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Date'),
                validator: (value) => value!.isEmpty ? 'Enter a date' : null,
                onTap: selectDate,
              ),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Time'),
                validator: (value) => value!.isEmpty ? 'Enter a time' : null,
                onTap: selectTime,
              ),
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(labelText: 'Hospital'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a location' : null,
              ),
              TextFormField(
                controller: _consultantController,
                decoration: InputDecoration(labelText: 'Consultant'),
                 validator: (value) =>
                    value!.isEmpty ? 'Enter a doctor' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Add Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
