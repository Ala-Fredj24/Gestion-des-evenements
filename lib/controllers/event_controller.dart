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
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la creation de l evenement : $e');
    }
  }

  Stream<List<EventModel>> getUpcomingEvents() {
    return _eventsRef.snapshots().map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .where((event) => event.isActive)
          .toList();

      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return events;
    });
  }

  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _eventsRef
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => EventModel.fromMap(doc.data(), doc.id))
              .toList();

          events.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          return events;
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
