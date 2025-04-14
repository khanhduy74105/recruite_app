import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/models/user_models.dart';

class JobModel {
  String id;
  String title;
  String creator;
  String description;
  List<String> jdUrls;
  List<File>? files;
  String companyName;
  String location;
  DateTime createdAt;
  UserModel? userModel;

  JobModel({
    required this.id,
    required this.title,
    required this.creator,
    required this.description,
    required this.jdUrls,
    this.files,
    required this.companyName,
    required this.location,
    required this.createdAt,
    this.userModel,
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
      jdUrls: List<String>.from(jsonDecode(json['jd_urls'] ?? '[]')),
      files: null,
      companyName: json['company_name'] as String,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['created_at']),
      creator: json['creator'] as String,
      userModel: json['user'] != null
          ? UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'jd_urls': jsonEncode(jdUrls), // Encode list to JSON string
      'company_name': companyName,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'creator': creator,
    };
  }
}