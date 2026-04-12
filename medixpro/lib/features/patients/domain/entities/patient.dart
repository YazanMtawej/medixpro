class Patient {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String? birthDate;
  final String? nationalId;
  final String phone;
  final String? email;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String bloodType;
  final String? allergies;
  final String? chronicDiseases;
  final String? previousSurgeries;
  final String? currentMedications;
  final String? notes;
  final String? createdAt;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.bloodType,
    this.birthDate,
    this.nationalId,
    this.email,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.allergies,
    this.chronicDiseases,
    this.previousSurgeries,
    this.currentMedications,
    this.notes,
    this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'male',
      phone: json['phone'] ?? '',
      bloodType: json['blood_type'] ?? 'unknown',
      birthDate: json['birth_date'],
      nationalId: json['national_id'],
      email: json['email'],
      address: json['address'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      allergies: json['allergies'],
      chronicDiseases: json['chronic_diseases'],
      previousSurgeries: json['previous_surgeries'],
      currentMedications: json['current_medications'],
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name.trim(),
      "age": age,
      "gender": gender,
      "phone": phone.trim(),
      "blood_type": bloodType,
      if (birthDate != null && birthDate!.isNotEmpty) "birth_date": birthDate,
      if (nationalId != null) "national_id": nationalId,
      if (email != null) "email": email,
      if (address != null) "address": address,
      if (emergencyContactName != null) "emergency_contact_name": emergencyContactName,
      if (emergencyContactPhone != null) "emergency_contact_phone": emergencyContactPhone,
      "allergies": allergies ?? "",
      "chronic_diseases": chronicDiseases ?? "",
      "previous_surgeries": previousSurgeries ?? "",
      "current_medications": currentMedications ?? "",
      "notes": notes ?? "",
    };
  }

  Patient copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? bloodType,
    String? birthDate,
    String? nationalId,
    String? email,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? allergies,
    String? chronicDiseases,
    String? previousSurgeries,
    String? currentMedications,
    String? notes,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      birthDate: birthDate ?? this.birthDate,
      nationalId: nationalId ?? this.nationalId,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      previousSurgeries: previousSurgeries ?? this.previousSurgeries,
      currentMedications: currentMedications ?? this.currentMedications,
      notes: notes ?? this.notes,
    );
  }
}