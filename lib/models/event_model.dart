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
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isFree => price == null || price == 0;

  bool get isFull => seatsAvailable <= 0;

  bool get isUpcoming => !dateTime.isBefore(DateTime.now());

  bool get canReserve => isActive && isUpcoming && !isFull;

  String get priceLabel =>
      isFree ? 'Gratuit' : '${price!.toStringAsFixed(2)} DT';

  String get dateLabel {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year} - $hour:$minute';
  }

  String get locationLabel {
    final cleanedAddress = address.trim();
    return cleanedAddress.isEmpty ? 'Lieu non precise' : cleanedAddress;
  }

  String get seatsLabel => '$seatsAvailable/$seatsTotal places';

  String get status {
    if (!isActive) {
      return 'Indisponible';
    }
    if (isFull) {
      return 'Complet';
    }
    return 'Disponible';
  }

  EventModel copyWith({
    String? id,
    String? organizerId,
    String? title,
    String? category,
    String? description,
    DateTime? dateTime,
    String? address,
    double? latitude,
    double? longitude,
    int? seatsTotal,
    int? seatsAvailable,
    double? price,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      seatsTotal: seatsTotal ?? this.seatsTotal,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      seatsTotal: _toInt(map['seatsTotal']),
      seatsAvailable: _toInt(map['seatsAvailable']),
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : rawCreatedAt is DateTime
          ? rawCreatedAt
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] is DateTime
          ? map['updatedAt']
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return 0;
  }
}
