enum ConnectionStatus { pending, accepted, declined }

class UserConnection {
  final String id; // Added id field
  final String userId;
  final String friendId;
  final String? senderId;
  ConnectionStatus status;
  DateTime createdAt;

  UserConnection({
    required this.id, // Added id to the constructor
    required this.userId,
    required this.friendId,
    this.senderId,
    this.status = ConnectionStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Getters
  String get getId => id; // Added getter for id
  String get getUserId => userId;
  String get getFriendId => friendId;
  String? get getSenderId => senderId;
  ConnectionStatus get getStatus => status;
  DateTime get getCreatedAt => createdAt;

  // Setters
  set setStatus(ConnectionStatus newStatus) {
    status = newStatus;
  }

  set setCreatedAt(DateTime newCreatedAt) {
    createdAt = newCreatedAt;
  }

  // Factory method to create an instance from a database map
  factory UserConnection.fromJson(Map<String, dynamic> json) {
    return UserConnection(
      id: json['id'], // Added id to fromJson
      userId: json['user_id'],
      friendId: json['friend_id'],
      senderId: json['sender_id'],
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Method to convert the instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Added id to toJson
      'user_id': userId,
      'friend_id': friendId,
      'sender_id': senderId,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }
}