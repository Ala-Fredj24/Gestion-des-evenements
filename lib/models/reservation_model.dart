import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  static const String statusConfirmed = 'confirmed';
  static const String statusCancelled = 'cancelled';

  final String? id;
  final String userId;
  final String eventId;
  final String organizerId;
  final int quantity;
  final String status;
  final DateTime? createdAt;

  const ReservationModel({
    this.id,
    required this.userId,
    required this.eventId,
    required this.organizerId,
    required this.quantity,
    this.status = statusConfirmed,
    this.createdAt,
  });

  bool get isConfirmed => status == statusConfirmed;

  bool get isCancelled => status == statusCancelled;

  String get quantityLabel => quantity > 1 ? '$quantity places' : '1 place';

  String get statusLabel {
    if (isConfirmed) {
      return 'Confirmee';
    }
    if (isCancelled) {
      return 'Annulee';
    }
    return status;
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? organizerId,
    int? quantity,
    String? status,
    DateTime? createdAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      organizerId: organizerId ?? this.organizerId,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'organizerId': organizerId,
      'quantity': quantity,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawCreatedAt = map['createdAt'];

    return ReservationModel(
      id: docId,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      organizerId: map['organizerId'] ?? '',
      quantity: _toInt(map['quantity']),
      status: map['status'] ?? statusConfirmed,
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
