import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String? id;
  final String userId;
  final String eventId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  const ReviewModel({
    this.id,
    required this.userId,
    required this.eventId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  String get ratingLabel => '$rating/5';

  bool get hasComment => comment.trim().isNotEmpty;

  ReviewModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawCreatedAt = map['createdAt'];

    return ReviewModel(
      id: docId,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      rating: _toInt(map['rating']),
      comment: map['comment'] ?? '',
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : rawCreatedAt is DateTime
          ? rawCreatedAt
          : null,
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return 0;
  }
}
