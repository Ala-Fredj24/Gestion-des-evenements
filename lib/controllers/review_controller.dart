import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviewsRef =>
      _firestore.collection('reviews');

  Future<String> addReview({
    required String userId,
    required String eventId,
    required int rating,
    required String comment,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Utilisateur non connecte.');
    }
    if (eventId.isEmpty) {
      throw Exception('Evenement introuvable.');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('La note doit etre entre 1 et 5.');
    }

    final cleanedComment = comment.trim();
    if (cleanedComment.isEmpty) {
      throw Exception('Ajoutez un commentaire.');
    }

    final review = ReviewModel(
      userId: userId,
      eventId: eventId,
      rating: rating,
      comment: cleanedComment,
    );

    try {
      final docRef = await _reviewsRef.add({
        ...review.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Acces refuse. Verifiez les permissions Firestore.');
      }
      throw Exception('Avis impossible : ${e.message ?? e.code}');
    }
  }

  Stream<List<ReviewModel>> getEventReviews(String eventId) {
    return _reviewsRef.where('eventId', isEqualTo: eventId).snapshots().map((
      snapshot,
    ) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();

      reviews.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return reviews;
    });
  }
}
