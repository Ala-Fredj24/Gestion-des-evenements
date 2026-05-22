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

  Future<void> updateEvent({
    required EventModel event,
    required String currentOrganizerId,
  }) async {
    final eventId = event.id;
    if (eventId == null || eventId.isEmpty) {
      throw Exception('Evenement introuvable.');
    }

    try {
      final eventRef = _eventsRef.doc(eventId);
      final snapshot = await eventRef.get();
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Evenement introuvable.');
      }

      final currentEvent = EventModel.fromMap(snapshot.data()!, snapshot.id);
      if (currentEvent.organizerId != currentOrganizerId) {
        throw Exception('Vous ne pouvez modifier que vos propres evenements.');
      }

      await eventRef.update({
        ...event.toMap(),
        'organizerId': currentEvent.organizerId,
        'createdAt': currentEvent.createdAt,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la modification de l evenement : $e');
    }
  }

  Future<void> deleteEvent({
    required String eventId,
    required String currentOrganizerId,
  }) async {
    if (eventId.isEmpty) {
      throw Exception('Evenement introuvable.');
    }

    try {
      final eventRef = _eventsRef.doc(eventId);
      final snapshot = await eventRef.get();
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Evenement introuvable.');
      }

      final event = EventModel.fromMap(snapshot.data()!, snapshot.id);
      if (event.organizerId != currentOrganizerId) {
        throw Exception('Vous ne pouvez supprimer que vos propres evenements.');
      }

      await eventRef.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l evenement : $e');
    }
  }

  Stream<List<EventModel>> getUpcomingEvents({String? category, bool? isFree}) {
    return _eventsRef.snapshots().map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .where((event) => event.isActive && event.isUpcoming)
          .where((event) {
            if (category == null || category.isEmpty) {
              return true;
            }
            return event.category == category;
          })
          .where((event) {
            if (isFree == null) {
              return true;
            }
            return event.isFree == isFree;
          })
          .toList();

      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return events;
    });
  }

  Stream<List<EventModel>> getEventsForDate(DateTime date) {
    return _eventsRef.snapshots().map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .where((event) => event.isActive)
          .where((event) => _isSameDay(event.dateTime, date))
          .toList();

      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return events;
    });
  }

  Stream<List<EventModel>> getEventsForMonth(DateTime month) {
    return _eventsRef.snapshots().map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .where((event) => event.isActive)
          .where(
            (event) =>
                event.dateTime.year == month.year &&
                event.dateTime.month == month.month,
          )
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
