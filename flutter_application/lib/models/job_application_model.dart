import 'package:flutter_application/models/user_models.dart';

enum ApplicationStatus {
  applied,
  rejected,
  interview,
  hired,
}

class JobApplicationModel {
  final String id;
  final String userId;
  final String jobId;
  final UserModel? user; // Added user field
  final ApplicationStatus status; // Changed from String to ApplicationStatus
  final DateTime appliedAt;

  JobApplicationModel( {
    this.user,
    required this.id,
    required this.userId,
    required this.jobId,
    required this.status,
    required this.appliedAt,
  });

  // Factory method to create a JobApplicationModel from JSON
  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      userId: json['user_id'],
      jobId: json['job_id'],
      status: _parseStatus(json['status']), // Convert string to enum
      appliedAt: DateTime.parse(json['applied_at']),
    );
  }

  // Method to convert a JobApplicationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user': user?.toJson(), // Convert user to JSON if not null
      'job_id': jobId,
      'status': status.name, // Convert enum to string
      'applied_at': appliedAt.toIso8601String(),
    };
  }

  // Helper method to parse string to ApplicationStatus
  static ApplicationStatus _parseStatus(String status) {
    switch (status) {
      case 'applied':
        return ApplicationStatus.applied;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'interview':
        return ApplicationStatus.interview;
      case 'hired':
        return ApplicationStatus.hired;
      default:
        throw Exception('Invalid application status: $status');
    }
  }

  // Optional: Add a copyWith method for immutability
  JobApplicationModel copyWith({
    String? id,
    String? userId,
    String? jobId,
    ApplicationStatus? status,
    DateTime? appliedAt,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      user: user ?? this.user,
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}