

import 'package:flutter/material.dart';
import 'package:health_app/Appointments/scanner_page.dart';

class EditAppointmentsPage extends StatefulWidget{
  final Appointment appointment;
  final Function(Appointment) onSave;

  const EditAppointmentsPage({
    super.key,
    required this.appointment,
    required this.onSave
  });

  @override
  State<EditAppointmentsPage> createState() => 
    _EditAppointmentsPageState();
}

  class _EditAppointmentsPageState extends State<EditAppointmentsPage> {
    late TextEditingController _dateController;
    late TextEditingController _timeController;
    late TextEditingController _consultantController;
    late TextEditingController _hospitalController;

    final _formKey = GlobalKey<FormState>();

    @override
    void initState(){
      super.initState();
      _dateController = TextEditingController(text: widget.appointment.formattedDate);
      _timeController = TextEditingController(text: widget.appointment.time);
      _consultantController = TextEditingController(text: widget.appointment.consultant);
      _hospitalController = TextEditingController(text: widget.appointment.hospital);
    }

    void _submitForm(){
      if(_formKey.currentState!.validate()){
        final updated = Appointment(
          formattedDate: _dateController.text, 
          time: _timeController.text, 
          consultant: _consultantController.text, 
          hospital: _hospitalController.text, 
          );

          widget.onSave(updated);
          Navigator.pop(context);
      }
    }

    Future<void> _selectDate() async {
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, 
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
                onTap: _selectDate,
              ),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Time'),
                validator: (value) => value!.isEmpty ? 'Enter a time' : null,
                onTap: _selectTime,
              ),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital'),
                validator: (value) => value!.isEmpty ? 'Enter a hospital' : null,
              ),
              TextFormField(
                controller: _consultantController,
                decoration: const InputDecoration(labelText: 'Consultant (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}


