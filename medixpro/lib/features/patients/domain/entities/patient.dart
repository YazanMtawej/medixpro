class Patient {
  final int id;
  final String name;
  final int age;
  final String phone;
  final String gender;
  final String? birthDate;
  final String? notes;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.gender,
    this.birthDate,
    this.notes,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'Male',
      birthDate: json['birth_date'],
      notes: json['notes'],
    );
  }

  /// 🔥 Clean JSON (no null issues)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "name": name.trim(),
      "age": age,
      "phone": phone.trim(),
      "gender": gender,
    };

    if (birthDate != null && birthDate!.isNotEmpty) {
      data["birth_date"] = birthDate;
    }

    /// 🔥 لا ترسل null أبداً
    data["notes"] = (notes == null || notes!.isEmpty) ? "" : notes;

    return data;
  }
}