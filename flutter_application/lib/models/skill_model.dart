class SkillModel {
  final String id;
  final String title;
  final String description;
  final int level;

  SkillModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
    };
  }
}