import 'package:flutter/material.dart';
import 'package:health_app/Appointments/scanner_page.dart';

class ManualAppointmentEntry extends StatefulWidget {
  final List<Appointment> appointments;
  final Function(Appointment) onSave;

  const ManualAppointmentEntry({
    super.key,
    required this.appointments,
    required this.onSave,
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

  void submitForm() {
    if (_formkey.currentState!.validate()) {
      final newAppt = Appointment(
        formattedDate: _dateController.text,
        time: _timeController.text,
        consultant: _consultantController.text.isNotEmpty
            ? _consultantController.text
            : 'N/A',
        hospital: _hospitalController.text.isNotEmpty
            ? _hospitalController.text
            : 'N/A',
      );

      widget.onSave(newAppt);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment added manually!')),
      );

      _dateController.clear();
      _timeController.clear();
      _consultantController.clear();
      _hospitalController.clear();
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
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
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
                    value!.isEmpty ? 'Enter a hospital' : null,
              ),
              TextFormField(
                controller: _consultantController,
                decoration: InputDecoration(labelText: 'Consultant (optional)'),
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
