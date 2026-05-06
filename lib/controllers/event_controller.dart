import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('events');

  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _eventsRef.add({
        ...event.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la creation de l evenement : $e');
    }
  }

  Stream<List<EventModel>> getUpcomingEvents() {
    return _eventsRef.orderBy('dateTime').snapshots().map((snapshot) {
      final now = DateTime.now();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .where((event) => !event.dateTime.isBefore(now))
          .toList();
    });
  }

  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _eventsRef
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EventModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _eventsRef.doc(eventId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return EventModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erreur lors de la recuperation de l evenement : $e');
    }
  }
}
