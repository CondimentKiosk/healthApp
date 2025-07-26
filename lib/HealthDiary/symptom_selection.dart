import 'package:flutter/material.dart';
import 'package:health_app/HealthDiary/health_diary_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomSelectionPage extends StatefulWidget {
  final List<Symptom> predefinedSymptoms;
  

  const SymptomSelectionPage({
    super.key,
    required this.predefinedSymptoms,
  });

  @override
  State<SymptomSelectionPage> createState() => _SymptomSelectionPageState();
}

class _SymptomSelectionPageState extends State<SymptomSelectionPage> {
  List<String> selectedSymptomNames = [];
  List<String> customSymptoms = [];
  final TextEditingController _symptomNameController = TextEditingController();

  late SharedPreferences prefs;

  @override
  void initState(){
    super.initState();
    loadStoredSymptoms();
  }

  Future<void> loadStoredSymptoms() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSymptomNames = prefs.getStringList('trackedSymptoms')?? [];
      customSymptoms = prefs.getStringList('customSymptoms') ?? [];
    });
  }

  Future<void> saveSymptoms() async {
  customSymptoms.removeWhere((sym) => !selectedSymptomNames.contains(sym));

  await prefs.setStringList('trackedSymptoms', selectedSymptomNames);
  await prefs.setStringList('customSymptoms', customSymptoms);

  Navigator.pop(context, selectedSymptomNames);
}


  void addCustomSymptom(){
    String name = _symptomNameController.text.trim();
    String lowerName = name.toLowerCase();
    if(name.isEmpty) return;

    bool alreadyExists = [
      ...widget.predefinedSymptoms.map((sym)=>sym.name),
      ...customSymptoms
    ].any((sym)=>sym.toLowerCase()==lowerName);
    
    if(alreadyExists){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Symptom '$name' already tracked"))
      );
      return;
    }
    final capitalised = capitalise(name);

    setState(() {
      customSymptoms.add(capitalised);
      selectedSymptomNames.add(capitalised);
    });

    _symptomNameController.clear();
  }

  String capitalise(String text){
    if(text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final predefined = widget.predefinedSymptoms.map((sym)=> sym.name).toSet();
    final allSymptoms = {
      ...predefined,
      ...customSymptoms,
      ...selectedSymptomNames,
    }.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text("Select Symptoms")),
      body: Column(
        children: [
          Expanded(child: ListView(
            children : allSymptoms.map((name){
              return CheckboxListTile(
                title: Text(name),
                value: selectedSymptomNames.contains(name), 
                onChanged: (value){
                  setState(() {
                    if(value==true){
                      selectedSymptomNames.add(name);
                    }else{
                      selectedSymptomNames.remove(name);
                    }
                  });
                }
                );
            }).toList(),
          ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: _symptomNameController,
                  decoration: const InputDecoration(
                    hintText: "Add a new symptom",
                  ),
                )
                ),
                IconButton(
                  onPressed: addCustomSymptom, 
                  icon: const Icon(Icons.add)
                  ),
              ],
            ),
            ),
            ElevatedButton(
              onPressed: saveSymptoms, 
              child: const Text("Save Symptoms For Tracking"))
        ],
      ),
    );
  }
}