class SkillModel {
  final String id;
  final String title;
  final String imgIllustrationLink;

  SkillModel({
    required this.id,
    required this.title,
    required this.imgIllustrationLink,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'],
      title: json['title'],
      imgIllustrationLink: json['img_illustration_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img_illustration_link': imgIllustrationLink,
    };
  }
}