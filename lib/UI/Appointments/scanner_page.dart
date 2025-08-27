// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ScannerPage extends StatefulWidget {
  final List<Appointment> savedAppointments;
  final void Function(Appointment) onSaveAppointment;

  const ScannerPage({
    super.key,
    required this.savedAppointments,
    required this.onSaveAppointment,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  File? selectedMedia;
  String? extractedText;
  Map<String, String> extracted = {};

  final ImagePicker _picker = ImagePicker();

  // 📸 Image picker
  Future<void> pickImage(ImageSource source) async {
  final XFile? pickedFile = await _picker.pickImage(
    source: source, // Camera or Gallery
  );

  if (pickedFile != null) {
    final File imageFile = File(pickedFile.path);
    final text = await extractText(imageFile);
    final appointment = extractAppointmentDetails(text);

    setState(() {
      selectedMedia = imageFile;
      extractedText = text;
      extracted = appointment;
    });
  }
}
void _showImageSourceDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}



  // 🔍 OCR function
  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textDetector.processImage(
      inputImage,
    );
    await textDetector.close();
    return recognizedText.text;
  }

  String formatToShortDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }

  DateTime parseExtractedDate(String raw) {
    final baseDate = raw
        .toLowerCase()
        .replaceAll(
          RegExp(
            r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
          ),
          "",
        )
        .replaceAllMapped(RegExp(r'(\d+)(st|nd|rd|th)'), (m) {
          return m.group(1)!;
        })
        .trim();
    print('base date $baseDate');
    final capitalised = baseDate
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');

    try {
      print('Parsing cleaned date: "$capitalised"');

      return DateFormat('d MMMM yyyy').parseStrict(capitalised);
    } catch (e) {
      throw Exception("Could not parse date: $raw");
    }
  }

  // 📋 Appointment details extractor
  Map<String, String> extractAppointmentDetails(String text) {
    final lines = text.split('\n');
    final Map<String, String> info = {};
    final dateRegex = RegExp(
      r'\b(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\b.*\b\d{4}\b',
      caseSensitive: false,
    );
    final timeRegex = RegExp(
      r'\b\d{1,2}:\d{2}\s*(am|pm)\b',
      caseSensitive: false,
    );
    final consultantRegex = RegExp(r'PROJ\s+[A-Z\s]+', caseSensitive: false);
    final hospitalRegex = RegExp(
      r'([A-Z,\s]{6,}HOSPITAL)',
      caseSensitive: false,
    );

    for (var line in lines) {
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null) {
        info['date'] = dateMatch.group(0)!;
      }

      final timeMatch = timeRegex.firstMatch(line);
      if (timeMatch != null) {
        info['time'] = timeMatch.group(0)!;
      }

      final consultantMatch = consultantRegex.firstMatch(line);
      if (consultantMatch != null) {
        info['consultant'] = consultantMatch.group(0)!;
      }

      final hospitalMatch = hospitalRegex.firstMatch(line);
      if (hospitalMatch != null) {
        info['hospital'] = hospitalMatch.group(0)!;
      }
    }

    return info;
  }

  Future<void> saveAppointment(Appointment appt) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList('appointments') ?? [];

    stored.add(jsonEncode(appt.toMap()));
    await prefs.setStringList('appointments', stored);
  }

  // 🧱 Full UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Text Recognition")),
      body: _buildUI(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: pickImage,
      //   child: const Icon(Icons.add),
      //),
    );
  }

  // 📦 Main screen layout
  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _styledButton(_uploadImage()),
          const SizedBox(height: 20),
          _imageView(),
          _appointmentInfoView(),
          _styledButton(_saveApptButton()),
          const SizedBox(height: 20),
          _extractTextView(),
        ],
      ),
    );
  }

  Widget _styledButton(Widget button) {
    return SizedBox(width: double.infinity, child: button);
  }

  // 🖼️ Image view
  Widget _imageView() {
    if (selectedMedia == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Pick an image for text recognition"),
      );
    }

    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height * 0.5,
        child: Image.file(selectedMedia!, fit: BoxFit.contain),
      ),
    );
  }

  // 📋 Appointment info card
  Widget _appointmentInfoView() {
    if (extracted.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Appointment Info',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (extracted['date'] != null)
            Text(
              '📅 Date: ${extracted['date']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          if (extracted['time'] != null)
            Text(
              '⏰ Time: ${extracted['time']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          if (extracted['consultant'] != null)
            Text(
              '🧑‍⚕️ Consultant: ${extracted['consultant']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          if (extracted['hospital'] != null)
            Text(
              '🏥 Hospital: ${extracted['hospital']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
        ],
      ),
    );
  }

  // 📄 Raw text output
  Widget _extractTextView() {
    if (selectedMedia == null || extractedText == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No text found"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(extractedText!, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _uploadImage() {
    return ElevatedButton(
      onPressed: () {
        _showImageSourceDialog(context);
      },
      child: const Text("Upload Image"),
    );
  }

  Widget _saveApptButton() {
    if (extracted.isEmpty) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: () async {
        final extractedDate = parseExtractedDate(extracted['date'] ?? '');

        final newAppt = Appointment(
          date: extractedDate,
          time: extracted['time'] ?? '',
          consultant: extracted['consultant'] ?? 'N/A',
          hospital: extracted['hospital'] ?? 'N/A',
        );

        widget.onSaveAppointment(newAppt);

        await saveAppointment(newAppt);

      setState(() {
        widget.savedAppointments.add(newAppt);
        extracted.clear();
      });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Appointment Saved!")));
      },
      child: const Text("Save Appointment"),
    );
  }
}

class Appointment {
  final int? appointment_id;
  final DateTime date;
  final String time;
  final String consultant;
  final String hospital;

  Appointment({
    this.appointment_id,
    required this.date,
    required this.time,
    required this.consultant,
    required this.hospital,
  });

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'apt_description': null,
      'date': date.toString().split(' ')[0],
      'time': time,
      'doctor': consultant,
      'category_id': null,
      'location': hospital,
      'apt_notes': null,
      'is_bookmarked': 0,
    };

    if (includeId && appointment_id != null) {
      map['appointment_id'] = appointment_id;
    }

    return map;
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointment_id: map['appointment_id'],
       date: map['date'] != null && map['date'].toString().isNotEmpty
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(), // fallback if null
      time: map['time']?.toString() ?? "", // fallback empty string
      consultant: map['doctor']?.toString() ?? "Unknown Doctor", // fallback
      hospital: map['location']?.toString() ?? "Unknown Location", // fallback
    );
  }

  void add(Appointment newAppt) {}
}
