class Patient {
  final String id;
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String bloodGroup;
  final String relationship;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.bloodGroup,
    required this.relationship,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "age": age,
      "gender": gender,
      "phone": phone,
      "bloodGroup": bloodGroup,
      "relationship": relationship,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      age: json["age"] ?? "",
      gender: json["gender"] ?? "Male",
      phone: json["phone"] ?? "",
      bloodGroup: json["bloodGroup"] ?? "",
      relationship: json["relationship"] ?? "Self",
    );
  }

  Patient copyWith({
    String? id,
    String? name,
    String? age,
    String? gender,
    String? phone,
    String? bloodGroup,
    String? relationship,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      relationship: relationship ?? this.relationship,
    );
  }
}