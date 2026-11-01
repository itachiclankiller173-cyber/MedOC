import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current logged-in user ID
  String get uid {
    return _auth.currentUser!.uid;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(
    String patientId,
  ) async {
    return await patientCollection.doc(patientId).get();
  }

  // =====================================================
  // MULTIPLE PATIENT COLLECTION
  // =====================================================

  CollectionReference<Map<String, dynamic>> get patientCollection {
    return _firestore.collection("users").doc(uid).collection("patients");
  }
  // =====================================================
  // PATIENT PROFILE
  // =====================================================
Future<void> saveVitalHistory({
  required String patientId,
  required String heartRate,
  required String bloodPressure,
  required String oxygen,
  required String temperature,
}) async {
  await patientCollection
      .doc(patientId)
      .collection("vital_history")
      .add({
    "heartRate": heartRate,
    "bloodPressure": bloodPressure,
    "oxygen": oxygen,
    "temperature": temperature,
    "timestamp": FieldValue.serverTimestamp(),
  });
}

Stream<QuerySnapshot<Map<String, dynamic>>> getVitalHistory(
  String patientId,
) {
  return patientCollection
      .doc(patientId)
      .collection("vital_history")
      .orderBy("timestamp")
      .snapshots();
}
  // ADD NEW PATIENT

  Future<String> addPatient({
    required String name,
    required String age,
    required String gender,
    required String phone,
    required String blood,
    required String relationship,
  }) async {
    final doc = await patientCollection.add({
      "name": name,
      "age": age,
      "gender": gender,
      "phone": phone,
      "blood": blood,
      "relationship": relationship,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // GET ALL PATIENTS

  Stream<QuerySnapshot<Map<String, dynamic>>> getPatients() {
    return patientCollection.orderBy("createdAt", descending: true).snapshots();
  }

  // GET SINGLE PATIENT

  // UPDATE PATIENT

  
  // =====================================================
// AI FEATURE HISTORY
// =====================================================

Future<void> saveAIHistory({
  required String patientId,
  required String feature,
  required String input,
  required String result,
}) async {
  await patientCollection
      .doc(patientId)
      .collection("ai_history")
      .add({
    "feature": feature,
    "input": input,
    "result": result,
    "timestamp": FieldValue.serverTimestamp(),
  });
}

Stream<QuerySnapshot<Map<String, dynamic>>> getAIHistory(
  String patientId,
) {
  return patientCollection
      .doc(patientId)
      .collection("ai_history")
      .orderBy("timestamp", descending: true)
      .snapshots();
}
Future updatePatient({
    required String patientId,

    required String name,
    required String age,
    required String gender,
    required String phone,
    required String blood,
    required String relationship,
  }) async {
    await patientCollection.doc(patientId).update({
      "name": name,
      "age": age,
      "gender": gender,
      "phone": phone,
      "blood": blood,
      "relationship": relationship,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // DELETE PATIENT

  Future deletePatient(String patientId) async {
    await patientCollection.doc(patientId).delete();
  }
  // =====================================================
  // MEDICAL HISTORY
  // =====================================================

  // SAVE MEDICAL HISTORY

  Future saveMedicalHistory({
    required String patientId,

    required String diseases,
    required String allergies,
    required String surgeries,
    required String medications,
    required String familyHistory,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("medical_history")
        .doc("history")
        .set({
          "diseases": diseases,
          "allergies": allergies,
          "surgeries": surgeries,
          "medications": medications,
          "familyHistory": familyHistory,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  // GET MEDICAL HISTORY

  Future<DocumentSnapshot<Map<String, dynamic>>> getMedicalHistory(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("medical_history")
        .doc("history")
        .get();
  }

  // UPDATE MEDICAL HISTORY

  Future updateMedicalHistory({
    required String patientId,

    required String diseases,
    required String allergies,
    required String surgeries,
    required String medications,
    required String familyHistory,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("medical_history")
        .doc("history")
        .update({
          "diseases": diseases,
          "allergies": allergies,
          "surgeries": surgeries,
          "medications": medications,
          "familyHistory": familyHistory,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  // DELETE MEDICAL HISTORY

  Future deleteMedicalHistory(String patientId) async {
    await patientCollection
        .doc(patientId)
        .collection("medical_history")
        .doc("history")
        .delete();
  }
  // =====================================================
  // VITAL SIGNS
  // =====================================================

  // SAVE VITAL SIGNS

  Future saveVitalSigns({
    required String patientId,

    required String heartRate,
    required String bloodPressure,
    required String oxygen,
    required String temperature,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("vital_signs")
        .doc("latest")
        .set({
          "heartRate": heartRate,
          "bloodPressure": bloodPressure,
          "oxygen": oxygen,
          "temperature": temperature,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  // GET VITAL SIGNS

  Future<DocumentSnapshot<Map<String, dynamic>>> getVitalSigns(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("vital_signs")
        .doc("latest")
        .get();
  }

  // UPDATE VITAL SIGNS

  Future updateVitalSigns({
    required String patientId,

    required String heartRate,
    required String bloodPressure,
    required String oxygen,
    required String temperature,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("vital_signs")
        .doc("latest")
        .update({
          "heartRate": heartRate,
          "bloodPressure": bloodPressure,
          "oxygen": oxygen,
          "temperature": temperature,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  // DELETE VITAL SIGNS

  Future deleteVitalSigns(String patientId) async {
    await patientCollection
        .doc(patientId)
        .collection("vital_signs")
        .doc("latest")
        .delete();
  }
  // =====================================================
  // SLEEP TRACKER
  // =====================================================

  Future saveSleep({
    required String patientId,

    required String sleepHours,
    required String bedTime,
    required String wakeUpTime,
    required String quality,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("sleep")
        .doc("latest")
        .set({
          "sleepHours": sleepHours,
          "bedTime": bedTime,
          "wakeUpTime": wakeUpTime,
          "quality": quality,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSleep(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("sleep")
        .doc("latest")
        .get();
  }

  Future updateSleep({
    required String patientId,

    required String sleepHours,
    required String bedTime,
    required String wakeUpTime,
    required String quality,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("sleep")
        .doc("latest")
        .update({
          "sleepHours": sleepHours,
          "bedTime": bedTime,
          "wakeUpTime": wakeUpTime,
          "quality": quality,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  Future deleteSleep(String patientId) async {
    await patientCollection
        .doc(patientId)
        .collection("sleep")
        .doc("latest")
        .delete();
  } // =====================================================
  // HYDRATION TRACKER
  // =====================================================

  Future saveHydration({
    required String patientId,

    required String waterIntake,
    required String goal,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("hydration")
        .doc("today")
        .set({
          "waterIntake": waterIntake,
          "goal": goal,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getHydration(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("hydration")
        .doc("today")
        .get();
  }

  Future updateHydration({
    required String patientId,

    required String waterIntake,
    required String goal,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("hydration")
        .doc("today")
        .update({
          "waterIntake": waterIntake,
          "goal": goal,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  Future deleteHydration(String patientId) async {
    await patientCollection
        .doc(patientId)
        .collection("hydration")
        .doc("today")
        .delete();
  }
  // =====================================================
  // MEDICINE REMINDER
  // =====================================================

  // ADD MEDICINE

  Future<String> saveMedicine({
    required String patientId,
    required String medicine,
    required String dosage,
    required String timing,
    required String food,
    required String startDate,
    required String endDate,
  }) async {
    final doc = await patientCollection
        .doc(patientId)
        .collection("medicines")
        .add({
          "medicine": medicine,
          "dosage": dosage,
          "timing": timing,
          "food": food,
          "startDate": startDate,
          "endDate": endDate,
          "createdAt": FieldValue.serverTimestamp(),
        });

    return doc.id;
  }
  // GET MEDICINES STREAM

  Stream<QuerySnapshot<Map<String, dynamic>>> medicineStream(String patientId) {
    return patientCollection
        .doc(patientId)
        .collection("medicines")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // UPDATE MEDICINE

  Future updateMedicine({
    required String patientId,
    required String medicineId,

    required String medicine,
    required String dosage,
    required String timing,
    required String food,
    required String startDate,
    required String endDate,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("medicines")
        .doc(medicineId)
        .update({
          "medicine": medicine,
          "dosage": dosage,
          "timing": timing,
          "food": food,

          "startDate": startDate,
          "endDate": endDate,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  // DELETE MEDICINE

  Future deleteMedicine({
    required String patientId,
    required String medicineId,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("medicines")
        .doc(medicineId)
        .delete();
  }

  // GET ALL MEDICINES

  Future<QuerySnapshot<Map<String, dynamic>>> getMedicines(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("medicines")
        .orderBy("createdAt", descending: true)
        .get();
  }
  // =====================================================
  // MEDICAL REPORTS
  // =====================================================

  Future saveReport({
    required String patientId,

    required String fileName,
    required String aiResult,
    required String reportType,
  }) async {
    await patientCollection.doc(patientId).collection("reports").add({
      "fileName": fileName,

      "aiResult": aiResult,

      "reportType": reportType,

      "createdAt": FieldValue.serverTimestamp(),

      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getReports(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("reports")
        .orderBy("createdAt", descending: true)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> reportsStream(String patientId) {
    return patientCollection
        .doc(patientId)
        .collection("reports")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future updateReport({
    required String patientId,

    required String reportId,

    required String fileName,
    required String aiResult,
    required String reportType,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("reports")
        .doc(reportId)
        .update({
          "fileName": fileName,

          "aiResult": aiResult,

          "reportType": reportType,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  Future deleteReport({
    required String patientId,

    required String reportId,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("reports")
        .doc(reportId)
        .delete();
  }
  // =====================================================
  // AI ASSISTANT CHAT HISTORY
  // =====================================================

  Future saveAIChat({
    required String patientId,

    required String message,

    required String sender,
  }) async {
    await patientCollection.doc(patientId).collection("ai_chat").add({
      "message": message,

      "sender": sender,

      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAIChats(String patientId) {
    return patientCollection
        .doc(patientId)
        .collection("ai_chat")
        .orderBy("timestamp")
        .snapshots();
  }

  Future deleteAIChat({
    required String patientId,

    required String chatId,
  }) async {
    await patientCollection
        .doc(patientId)
        .collection("ai_chat")
        .doc(chatId)
        .delete();
  }

  Future clearAIChat(String patientId) async {
    final chats = await patientCollection
        .doc(patientId)
        .collection("ai_chat")
        .get();

    for (var doc in chats.docs) {
      await doc.reference.delete();
    }
  }
  // =====================================================
  // DASHBOARD STATISTICS
  // =====================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getDashboardVitals(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("vital_signs")
        .doc("latest")
        .get();
  }

  Future<int> getMedicineCount(String patientId) async {
    final data = await patientCollection
        .doc(patientId)
        .collection("medicines")
        .get();

    return data.docs.length;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDashboardHydration(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("hydration")
        .doc("today")
        .get();
  }
  // ============================================================
  // PATIENT MEDICAL HISTORY
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getDashboardSleep(
    String patientId,
  ) async {
    return await patientCollection
        .doc(patientId)
        .collection("sleep")
        .doc("latest")
        .get();
  }
Future<void> saveBodySymptom({
  required String userId,
  required String bodyRegion,
  required String side,
  required String symptom,
  required int painSeverity,
  required String duration,
  required String notes,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('bodySymptoms')
      .add({
    'userId': userId,
    'bodyRegion': bodyRegion,
    'side': side,
    'symptom': symptom,
    'painSeverity': painSeverity,
    'duration': duration,
    'notes': notes,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
  Stream<DocumentSnapshot<Map<String, dynamic>>> vitalStream(String patientId) {
    return patientCollection
        .doc(patientId)
        .collection("vital_signs")
        .doc("latest")
        .snapshots();
  }
}
