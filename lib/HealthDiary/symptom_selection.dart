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
  final TextEditingController _symptomNameController = TextEditingController();

  @override
  void initState(){
    super.initState();
    loadStoredSymptoms();
  }

  Future<void> loadStoredSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSymptomNames = prefs.getStringList('trackedSymptoms')?? [];
    });
  }

  Future<void> saveSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('trackedSymptoms', selectedSymptomNames);
    Navigator.pop(context, selectedSymptomNames);
  }

  void addCustomSymptom(){
    String name = _symptomNameController.text.trim();
    if(name.isNotEmpty && !selectedSymptomNames.contains(name)){
      setState(() {
        selectedSymptomNames.add(name);
      });
      _symptomNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSymtoms = [...widget.predefinedSymptoms.map((sym)=> sym.name)];

    return Scaffold(
      appBar: AppBar(title: const Text("Select Symptoms")),
      body: Column(
        children: [
          Expanded(child: ListView(
            children : allSymtoms.map((name){
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