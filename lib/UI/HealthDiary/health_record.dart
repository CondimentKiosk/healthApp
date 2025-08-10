import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:health_app/UI/HealthDiary/health_rating.dart';
import 'package:intl/intl.dart';

class HealthRecordPage extends StatefulWidget {
  final List<SymptomEntry> healthReport;

  const HealthRecordPage({super.key, required this.healthReport});

  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Report"),),
      body: _buildUI()
    );
  }

  Widget _buildUI(){
    return SingleChildScrollView(
      child: Column(
        children: [
          _showHealthRecord()
        ],
      ),
    );
  }

  Widget _showHealthRecord() {
    final records = widget.healthReport.reversed.toList();

    if (records.isEmpty) {
      return const Center(child: Text("No health data yet"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final report = records[index];
final date = DateFormat('dd/MM/yy @ h:mma').format(report.timeStamp);
        final symptoms = report.symptomRatings;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ExpansionTile(
title: Text(date),
            children: symptoms.entries.map<Widget>((entry) {
              final name = entry.key;
              final rating = entry.value;
              return ListTile(title: Text(name), trailing: Text("$rating/10"));
            }).toList(),
          ),
        );
      },
    );
  }
}
