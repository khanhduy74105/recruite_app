class EducationModel {
  final String id;
  final String userId;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;

  EducationModel({
    required this.id,
    required this.userId,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    this.startDate,
    this.endDate,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'],
      userId: json['user_id'],
      school: json['school'],
      degree: json['degree'],
      fieldOfStudy: json['field_of_study'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'school': school,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}