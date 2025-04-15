import '../features/profile/model/timeline_item.dart';

class EducationModel implements TimelineItem{
  final String id;
  final String userId;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String? endDate;

  EducationModel({
    required this.id,
    required this.userId,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'],
      userId: json['user_id'],
      school: json['school'],
      degree: json['degree'],
      fieldOfStudy: json['field_of_study'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'school': school,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}