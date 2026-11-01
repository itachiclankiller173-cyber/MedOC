import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient.dart';

class PatientService {
  static const String patientsKey = "patients";
  static const String selectedPatientKey = "selected_patient";

  // Save all patients
  Future<void> savePatients(List<Patient> patients) async {
    final prefs = await SharedPreferences.getInstance();

    final patientList = patients
        .map((patient) => jsonEncode(patient.toJson()))
        .toList();

    await prefs.setStringList(patientsKey, patientList);
  }

  // Load all patients
  Future<List<Patient>> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();

    final patientList = prefs.getStringList(patientsKey) ?? [];

    final List<Patient> patients = [];

    for (final item in patientList) {
      try {
        final json = jsonDecode(item);

        if (json is Map<String, dynamic>) {
          patients.add(Patient.fromJson(json));
        } else if (json is Map) {
          patients.add(Patient.fromJson(Map<String, dynamic>.from(json)));
        }
      } catch (e) {
        debugPrint("PATIENT LOAD ERROR: $e");
      }
    }

    return patients;
  }

  // Add patient
  Future<void> addPatient(Patient patient) async {
    final patients = await loadPatients();

    // Prevent duplicate IDs
    final exists = patients.any((p) => p.id == patient.id);

    if (!exists) {
      patients.add(patient);
      await savePatients(patients);
    }
  }

  // Update patient
  Future<void> updatePatient(Patient updatedPatient) async {
    final patients = await loadPatients();

    final index = patients.indexWhere((p) => p.id == updatedPatient.id);

    if (index != -1) {
      patients[index] = updatedPatient;
    } else {
      patients.add(updatedPatient);
    }

    await savePatients(patients);
  }

  // Delete patient
  Future<void> deletePatient(String id) async {
    final patients = await loadPatients();

    patients.removeWhere((p) => p.id == id);

    await savePatients(patients);

    final selectedPatient = await getSelectedPatient();

    if (selectedPatient == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(selectedPatientKey);
    }
  }

  // Save selected patient
  Future<void> setSelectedPatient(String id) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(selectedPatientKey, id);

    debugPrint("SELECTED PATIENT SAVED: $id");
  }

  // Get selected patient
  Future<Patient?> getSelectedPatient() async {
    final prefs = await SharedPreferences.getInstance();

    final selectedId = prefs.getString(selectedPatientKey);

    debugPrint("SELECTED PATIENT ID: $selectedId");

    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }

    final patients = await loadPatients();

    for (final patient in patients) {
      if (patient.id == selectedId) {
        debugPrint("SELECTED PATIENT FOUND: ${patient.name}");

        return patient;
      }
    }

    debugPrint("SELECTED PATIENT NOT FOUND");

    return null;
  }

  // Get selected patient ID directly
  Future<String?> getSelectedPatientId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(selectedPatientKey);
  }

  // Clear selected patient only
  Future<void> clearSelectedPatient() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(selectedPatientKey);
  }

  // Clear all patients
  Future<void> clearPatients() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(patientsKey);
    await prefs.remove(selectedPatientKey);
  }
}
