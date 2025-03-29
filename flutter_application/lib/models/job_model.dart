import 'dart:convert';
import 'dart:io';

class JobModel {
  String id;
  String title;
  String description;
  List<String> jdUrls;
  List<File>? files;
  String companyName;
  String location;
  DateTime createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.jdUrls,
    required this.files,
    required this.companyName,
    required this.location,
    required this.createdAt,
  });

  // Setters
  set setId(String value) => id = value;
  set setTitle(String value) => title = value;
  set setDescription(String value) => description = value;
  set setJdUrls(List<String> value) => jdUrls = value;
  set setFiles(List<File>? value) => files = value;
  set setCompanyName(String value) => companyName = value;
  set setLocation(String value) => location = value;
  set setCreatedAt(DateTime value) => createdAt = value;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      jdUrls: List<String>.from(jsonDecode(json['jd_urls']) ??'[]'),
      files: null,
      companyName: json['company_name'] as String,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'jdUrls': jdUrls,
      'files': files,
      'companyName': companyName,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
