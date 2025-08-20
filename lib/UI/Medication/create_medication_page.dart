import 'package:flutter/material.dart';
import 'package:health_app/UI/Medication/medication_page.dart';
import 'package:numberpicker/numberpicker.dart';

class CreateMedication extends StatefulWidget {
  final List<Medication> savedMedications;
  final Function(Medication) onSave;

  const CreateMedication({
    super.key,
    required this.savedMedications,
    required this.onSave,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CreateMedicationState createState() => _CreateMedicationState();
}

class _CreateMedicationState extends State<CreateMedication> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _medTypeController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _frequencyTypeController =
      TextEditingController();
  final TextEditingController _combinedFrequencyController =
      TextEditingController();
  final TextEditingController _numRemainingController = TextEditingController();
  final TextEditingController _reminderLevelController =
      TextEditingController();

  void submitForm() {
    if (_formkey.currentState!.validate()){
      final newMed = Medication(
        id: null,
        name: _nameController.text,
        medType: _medTypeController.text,
        dosage: num.parse(_dosageController.text.trim()),
        frequency: int.parse(_frequencyController.text.trim()), 
        frequencyType: _frequencyTypeController.text,
        numRemaining: int.parse(_numRemainingController.text.trim()),
        reminderLevel: int.parse(_reminderLevelController.text.trim()),
      );

      widget.onSave(newMed);
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('New Medication Added!')));

      _nameController.clear();
      _medTypeController.clear();
      _dosageController.clear();
      _frequencyController.clear();
      _frequencyTypeController.clear();
      _numRemainingController.clear();
      _reminderLevelController.clear();
    }
  }

  Future<void> selectMedType() async {
    final String? picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Select Type of Medication"),
          children: [
            SimpleDialogOption(
              child: Text("Tablet"),
              onPressed: () => Navigator.pop(context, "Tablet"),
            ),
            SimpleDialogOption(
              child: Text("Liquid"),
              onPressed: () => Navigator.pop(context, "Liquid"),
            ),
            SimpleDialogOption(
              child: Text("Injection"),
              onPressed: () => Navigator.pop(context, "Injection"),
            ),
          ],
        );
      },
    );
    if (picked != null) {
      setState(() {
        _medTypeController.text = picked;
      });
    }
  }

  Future<void> selectDosage() async {
    int selectedTablets = 1;
    double selectedMl = 5.0;
    int selectedInject = 1;

    final picked = await showDialog<num>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget content;

            if (_medTypeController.text == "Tablet") {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select Tablets per Dose"),
                  NumberPicker(
                    value: selectedTablets,
                    minValue: 0,
                    maxValue: 10,
                    step: 1,
                    itemHeight: 50,
                    onChanged: (value) =>
                        setState(() => selectedTablets = value),
                  ),
                ],
              );
            } else if (_medTypeController.text == "Liquid") {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select Ml per Dose"),
                  Slider(
                    value: selectedMl,
                    min: 0,
                    max: 50,
                    divisions: ((50) / 0.5).round(),
                    label: "${selectedMl.toStringAsFixed(1)} ",
                    onChanged: (value) => setState(() => selectedMl = value),
                  ),
                ],
              );
            } else if (_medTypeController.text == "Injection") {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select Injections per Dose"),
                  DropdownButton<int>(
                    value: selectedInject,
                    items: [1, 2, 3, 4, 5]
                        .map(
                          (each) => DropdownMenuItem(
                            value: each,
                            child: Text(
                              "$each Injection${each > 1 ? 's' : ''}",
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      if (value != null) selectedInject = value;
                    }),
                  ),
                ],
              );
            } else {
              content = const Text("Please select medication type");
            }
            return AlertDialog(
              title: Text("Select Dosage"),
              content: content,
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    if (_medTypeController.text == "Tablet") {
                      Future.microtask(() {
                        Navigator.of(context).pop(selectedTablets);
                      });
                    } else if (_medTypeController.text == "Liquid") {
                      Future.microtask(() {
                        Navigator.of(context).pop(selectedMl);
                      });
                    } else if (_medTypeController.text == "Injection") {
                      Future.microtask(() {
                        Navigator.of(context).pop(selectedInject);
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
  setState(() {
    _dosageController.text = picked is double
        ? picked.toStringAsFixed(1)
        : picked.toString();
  });
}

  }

  Future<void> selectFrequency() async {
    int frequency = 1;
    String frequencyType = "Day";

    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("How often do you take this medication?"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Frequency"),
                  NumberPicker(
                    value: frequency,
                    minValue: 1,
                    maxValue: 10,
                    onChanged: (value) => setState(() => frequency = value),
                  ),
                  const SizedBox(height: 10),
                  const Text("Per:"),
                  DropdownButton<String>(
                    value: frequencyType,
                    items: ["Day", "Week", "Month"]
                        .map(
                          (each) =>
                              DropdownMenuItem(value: each, child: Text(each)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => frequencyType = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'frequency': frequency,
                      'frequencyType': frequencyType,
                    });
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() {
        _frequencyController.text = picked['frequency']
            .toString(); // Number string
        _frequencyTypeController.text = picked['frequencyType']; // Unit string
        _combinedFrequencyController.text =
            "${picked['frequency']} time${picked['frequency'] > 1 ? 's' : ''} per ${picked['frequencyType']}";
      });
    }
  }

  Future<void> selectNumberRemaining() async {
    int selectedValue = 1;

    final int? picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Stock"),
              content: NumberPicker(
                value: selectedValue,
                minValue: 0,
                maxValue: 500,
                step: 1,
                itemHeight: 50,
                onChanged: (value) => setState(() => selectedValue = value),
              ),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(selectedValue);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _numRemainingController.text = picked.toString();
      });
    }
  }

  Future<void> selectReminderLevel() async {
    int selectedValue = 1;

    final int? picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "How many days before you run out do you want reminded to order more?",
              ),
              content: NumberPicker(
                value: selectedValue,
                minValue: 0,
                maxValue: 500,
                step: 1,
                itemHeight: 50,
                onChanged: (value) => setState(() => selectedValue = value),
              ),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(selectedValue);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderLevelController.text = picked.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add a New Medication")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? "Enter a Name" : null,
              ),
              TextFormField(
                controller: _medTypeController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Medication Type"),
                validator: (value) =>
                    value!.isEmpty ? "Enter Medication Type" : null,
                onTap: selectMedType,
              ),
              TextFormField(
                controller: _dosageController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Dosage"),
                validator: (value) => value!.isEmpty ? "Enter a Dosage" : null,
                onTap: selectDosage,
              ),
              TextFormField(
                controller: _combinedFrequencyController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "How Often is your Dosage?",
                ),
                validator: (value) => value!.isEmpty ? "Enter Frequency" : null,
                onTap: selectFrequency,
              ),
              TextFormField(
                controller: _numRemainingController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Current Stock"),
                validator: (value) =>
                    value!.isEmpty ? "Enter your Stock" : null,
                onTap: selectNumberRemaining,
              ),
              TextFormField(
                controller: _reminderLevelController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Select low stock alert(Optional)",
                ),
                onTap: selectReminderLevel,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text("Add Medication"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
