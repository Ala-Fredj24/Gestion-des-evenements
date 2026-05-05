import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String? id;
  final String organizerId;
  final String title;
  final String category;
  final String description;
  final DateTime dateTime;
  final String address;
  final double latitude;
  final double longitude;
  final int seatsTotal;
  final int seatsAvailable;
  final double? price;
  final DateTime? createdAt;

  EventModel({
    this.id,
    required this.organizerId,
    required this.title,
    required this.category,
    required this.description,
    required this.dateTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.seatsTotal,
    required this.seatsAvailable,
    this.price,
    this.createdAt,
  });

  bool get isFree => price == null || price == 0;

  String get status {
    if (seatsAvailable <= 0) {
      return 'Complet';
    }
    return 'Disponible';
  }

  Map<String, dynamic> toMap() {
    return {
      'organizerId': organizerId,
      'title': title,
      'category': category,
      'description': description,
      'dateTime': dateTime,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'seatsTotal': seatsTotal,
      'seatsAvailable': seatsAvailable,
      'price': price,
      'createdAt': createdAt,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawDateTime = map['dateTime'];
    final rawCreatedAt = map['createdAt'];

    return EventModel(
      id: docId,
      organizerId: map['organizerId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      dateTime: rawDateTime is Timestamp
          ? rawDateTime.toDate()
          : rawDateTime is DateTime
          ? rawDateTime
          : DateTime.now(),
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      seatsTotal: (map['seatsTotal'] ?? 0).toInt(),
      seatsAvailable: (map['seatsAvailable'] ?? 0).toInt(),
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : rawCreatedAt is DateTime
          ? rawCreatedAt
          : null,
    );
  }
}
