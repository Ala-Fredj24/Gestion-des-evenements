import 'package:flutter_test/flutter_test.dart';

import 'package:devmob_developpement/models/event_model.dart';
import 'package:devmob_developpement/models/place_model.dart';
import 'package:devmob_developpement/models/review_model.dart';

void main() {
  group('EventModel display helpers', () {
    test('formats free upcoming event state', () {
      final event = EventModel(
        id: 'event-1',
        organizerId: 'organizer-1',
        title: 'Concert',
        category: 'Culture',
        description: 'Concert public',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        address: 'Theatre municipal',
        latitude: 36.8,
        longitude: 10.18,
        seatsTotal: 20,
        seatsAvailable: 8,
      );

      expect(event.isFree, isTrue);
      expect(event.canReserve, isTrue);
      expect(event.priceLabel, 'Gratuit');
      expect(event.status, 'Disponible');
      expect(event.hasMapLocation, isTrue);
    });

    test('blocks full events', () {
      final event = EventModel(
        organizerId: 'organizer-1',
        title: 'Match',
        category: 'Sport',
        description: 'Match local',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        address: 'Stade',
        latitude: 0,
        longitude: 0,
        seatsTotal: 10,
        seatsAvailable: 0,
        price: 15,
      );

      expect(event.isFull, isTrue);
      expect(event.canReserve, isFalse);
      expect(event.status, 'Complet');
      expect(event.hasMapLocation, isFalse);
    });
  });

  group('ReviewModel', () {
    test('maps rating and comment helpers', () {
      const review = ReviewModel(
        userId: 'user-1',
        eventId: 'event-1',
        rating: 4,
        comment: 'Tres bon evenement.',
      );

      expect(review.ratingLabel, '4/5');
      expect(review.hasComment, isTrue);
      expect(review.toMap()['rating'], 4);
    });
  });

  group('PlaceModel', () {
    test('uses official Nominatim name when available', () {
      final place = PlaceModel.fromNominatim({
        'display_name': 'Theatre Municipal, Tunis, Tunisie',
        'namedetails': {'name': 'Theatre Municipal'},
        'lat': '36.79920',
        'lon': '10.18150',
      });

      expect(place.name, 'Theatre Municipal');
      expect(place.latitude, 36.79920);
      expect(place.longitude, 10.18150);
    });
  });
}
