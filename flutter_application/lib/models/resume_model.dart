class ResumeModel {
  final String id;
  final String url;
  final String data;

  ResumeModel({
    required this.id,
    required this.url,
    required this.data,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'],
      url: json['url'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'data': data,
    };
  }
}