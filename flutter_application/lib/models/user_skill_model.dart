import 'package:flutter_application/models/skill_model.dart';

class UserSkillModel {
  final String userId;
  final String skillId;
  final int level;
  final double yearExp;
  final SkillModel skill;

  UserSkillModel({
    required this.userId,
    required this.skillId,
    required this.level,
    required this.yearExp,
    required this.skill,
  });

  factory UserSkillModel.fromJson(Map<String, dynamic> json, SkillModel skill) {
    return UserSkillModel(
      userId: json['user_id'],
      skillId: json['skill_id'],
      level: json['level'],
      yearExp: double.parse(json['year_exp'].toString()),
      skill: skill,
    );
  }
}