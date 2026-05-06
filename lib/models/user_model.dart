import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.createdAt,
  });

  bool get isOrganizer => role == 'organizer';

  bool get isUser => role == 'user';

  String get nameOrEmail {
    final cleanedName = displayName.trim();
    return cleanedName.isEmpty ? email : cleanedName;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    final rawCreatedAt = map['createdAt'];

    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : rawCreatedAt is DateTime
          ? rawCreatedAt
          : null,
    );
  }
}
