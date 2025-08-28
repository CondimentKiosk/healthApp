import 'package:flutter/material.dart';
import 'package:health_app/Services/health_diary_services.dart';
import 'package:health_app/UI/HealthDiary/health_rating.dart';
import 'package:intl/intl.dart';

class HealthRecordPage extends StatefulWidget {
  final List<SymptomEntry> healthReport;
  final int patientId;
  final int userId;

  const HealthRecordPage({
    super.key,
    required this.healthReport,
    required this.patientId,
    required this.userId,
  });

  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {


  @override
  void initState() {
    super.initState();
    _loadHealthReport();
  }

  Future<void> _loadHealthReport() async {
    try {
      final entries = await getHealthReport(widget.patientId);
      setState(() {
        widget.healthReport.clear();
        widget.healthReport.addAll(entries);
      });
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load health report: $e')),
      );
      });
      
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Report")),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(children: [_showHealthRecord()]),
    );
  }

  Widget _showHealthRecord() {
    final records = widget.healthReport.toList();

    if (records.isEmpty) {
      return const Center(child: Text("No health data yet"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final report = records[index];
        final date = DateFormat('dd/MM/yy HH:mm').format(report.timeStamp);
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
