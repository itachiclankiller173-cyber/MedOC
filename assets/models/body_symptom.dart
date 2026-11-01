class BodySymptom {
  final String userId;
  final String bodyRegion;
  final String side;
  final String symptom;
  final int painSeverity;
  final String duration;
  final String notes;
  final DateTime timestamp;

  BodySymptom({
    required this.userId,
    required this.bodyRegion,
    required this.side,
    required this.symptom,
    required this.painSeverity,
    required this.duration,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bodyRegion': bodyRegion,
      'side': side,
      'symptom': symptom,
      'painSeverity': painSeverity,
      'duration': duration,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  factory BodySymptom.fromMap(Map<String, dynamic> map) {
    return BodySymptom(
      userId: map['userId'] ?? '',
      bodyRegion: map['bodyRegion'] ?? '',
      side: map['side'] ?? '',
      symptom: map['symptom'] ?? '',
      painSeverity: map['painSeverity'] ?? 0,
      duration: map['duration'] ?? '',
      notes: map['notes'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
    );
  }
}