class ExperienceModel {
  final String id;
  final String userId;
  final String company;
  final String position;
  final String? startDate;
  final String? endDate;
  final String description;

  ExperienceModel({
    required this.id,
    required this.userId,
    required this.company,
    required this.position,
    this.startDate,
    this.endDate,
    required this.description,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'],
      userId: json['user_id'],
      company: json['company'],
      position: json['position'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company': company,
      'position': position,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
    };
  }
}