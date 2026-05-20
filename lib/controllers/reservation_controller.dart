import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../models/reservation_model.dart';

class ReservationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('events');

  CollectionReference<Map<String, dynamic>> get _reservationsRef =>
      _firestore.collection('reservations');

  Future<String> createReservation({
    required EventModel event,
    required String userId,
    required int quantity,
  }) async {
    final eventId = event.id;

    if (eventId == null || eventId.isEmpty) {
      throw Exception('Evenement introuvable.');
    }
    if (userId.isEmpty) {
      throw Exception('Utilisateur non connecte.');
    }
    if (quantity <= 0) {
      throw Exception('Choisissez au moins une place.');
    }

    final reservationRef = _reservationsRef.doc();
    final eventRef = _eventsRef.doc(eventId);

    try {
      await _firestore.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventRef);

        if (!eventSnapshot.exists || eventSnapshot.data() == null) {
          throw Exception('Evenement introuvable.');
        }

        final freshEvent = EventModel.fromMap(
          eventSnapshot.data()!,
          eventSnapshot.id,
        );

        if (!freshEvent.isActive) {
          throw Exception('Cet evenement n est plus disponible.');
        }
        if (!freshEvent.isUpcoming) {
          throw Exception('Cet evenement est deja passe.');
        }
        if (freshEvent.isFull) {
          throw Exception('Cet evenement est complet.');
        }
        if (freshEvent.seatsAvailable < quantity) {
          throw Exception('Places insuffisantes.');
        }

        final reservation = ReservationModel(
          id: reservationRef.id,
          userId: userId,
          eventId: eventId,
          organizerId: freshEvent.organizerId,
          quantity: quantity,
        );

        transaction.update(eventRef, {
          'seatsAvailable': freshEvent.seatsAvailable - quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.set(reservationRef, {
          ...reservation.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      return reservationRef.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Acces refuse. Verifiez les permissions Firestore.');
      }
      throw Exception('Reservation impossible : ${e.message ?? e.code}');
    }
  }

  Stream<List<ReservationModel>> getUserReservations(String userId) {
    return _reservationsRef.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final reservations = snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
          .toList();

      reservations.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return reservations;
    });
  }
}
