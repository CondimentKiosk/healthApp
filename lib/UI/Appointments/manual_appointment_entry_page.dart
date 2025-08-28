import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health_app/Services/appointment_services.dart';
import 'package:health_app/UI/Appointments/scanner_page.dart';
import 'package:intl/intl.dart';

class ManualAppointmentEntry extends StatefulWidget {
  final Appointment? prefilledAppointment;
  final File? referenceImage; 

  const ManualAppointmentEntry({
    super.key,
    this.prefilledAppointment,
    this.referenceImage,
  });

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
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.prefilledAppointment != null) {
      final appt = widget.prefilledAppointment!;
      _dateController.text = DateFormat('dd/MM/yyyy').format(appt.date);
      _timeController.text = normaliseTime(appt.time);
      _hospitalController.text = appt.hospital;
      _consultantController.text = appt.consultant;
      _notesController.text = appt.notes ?? ''; 
    }
  }

  void submitForm() async {
    String? base64Image;

  if (widget.referenceImage != null) {
    final bytes = await widget.referenceImage!.readAsBytes();
    base64Image = base64Encode(bytes);
  }

    if (_formkey.currentState!.validate()) {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      final newAppt = Appointment(
        date: parsedDate,
        time: _timeController.text,
        consultant: _consultantController.text,
        hospital: _hospitalController.text,
        notes: _notesController.text,
        //imagePath: base64Image,
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

  String normaliseTime(String rawTime) {
  try {
    // Try parsing with am/pm first
    final parsed = DateFormat.jm().parse(rawTime); // handles "10:40 am" or "1:30pm"
    return DateFormat.Hm().format(parsed); // outputs "10:40" or "13:30"
  } catch (_) {
    try {
      // If no am/pm, maybe it’s already 24hr
      final parsed = DateFormat.Hm().parse(rawTime);
      return DateFormat.Hm().format(parsed);
    } catch (e) {
      throw Exception("Could not parse time: $rawTime");
    }
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
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                if (widget.referenceImage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reference Image:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Image.file(
                          widget.referenceImage!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
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
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes about the appointment',
                  ),
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
      ),
    );
  }
}