class PostModel {
  final String id;
  final String creatorId;
  final String content;
  final List<String> imageLinks;
  final DateTime createdAt;
  final List<String> likes;
  final List<String> comments;
  final String visibility; // e.g., "public", "connections", "private"

  PostModel({
    required this.id,
    required this.creatorId,
    required this.content,
    required this.imageLinks,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.visibility,
  });

  // Factory method to create a PostModel from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      creatorId: json['creator_id'],
      content: json['content'],
      imageLinks: List<String>.from(json['image_links']),
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes']),
      comments: List<String>.from(json['comments']),
      visibility: json['visibility'],
    );
  }

  // Method to convert a PostModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'content': content,
      'image_links': imageLinks,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'visibility': visibility,
    };
  }
}