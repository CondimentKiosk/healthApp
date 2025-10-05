# Health Management App

# 🏥 Health App – Appointment Tracker & Health Diary
A Flutter-based mobile application designed to help users manage their medical appointments and track their health symptoms. Built as part of a Master's in Software Development at Queen's University Belfast.

## ✨ Features
- Hospital Appointment Tracker: Add, edit, and delete appointments. View upcoming appointments in a clean, organized list. Data stored in a MySQL database (managed via phpMyAdmin).
- Health Diary: Select symptoms from a pre-defined list or add custom symptoms. Rate symptoms on a 1–10 scale with sliders. Option to ignore certain symptoms for flexibility. View past entries with timestamps. Symptom lists persist across sessions.

## 🛠️ Tech Stack
- Frontend: Flutter (Dart)  
- Backend/Database: MySQL with phpMyAdmin  
- State Management: Flutter setState / Provider (if applicable)  
- Platform Support: Android & iOS  

## 🚀 Installation & Setup
1. Set Up the Database  
   - Import the provided SQL schema into phpMyAdmin.  
   - Update database connection details in the backend config.  
2. Install Dependencies  
   flutter pub get  
3. Run the App  
   flutter run  - recommend to test on a physical device rather than browser or emulator to have access to all features.

## 📖 Usage
- Appointments Page → Add, edit, and view your hospital appointments.
- Medications Page → Add, edit, and track medication stock 
- Health Diary Page → Track daily symptoms with severity ratings and notes.  

## 👨‍💻 Author
Developed by Joshua Culbert  
Master’s in Software Development, Queen’s University Belfast  


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
