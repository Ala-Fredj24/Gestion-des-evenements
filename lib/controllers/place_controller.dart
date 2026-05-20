import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/place_model.dart';

class PlaceController {
  static const _baseUrl = 'https://nominatim.openstreetmap.org';
  static const _headers = {
    'User-Agent': 'devmob-events-student-app/1.0',
    'Accept': 'application/json',
  };

  Future<List<PlaceModel>> searchPlaces(String query) async {
    final cleanedQuery = query.trim();
    if (cleanedQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'format': 'json',
        'q': cleanedQuery,
        'limit': '8',
        'addressdetails': '1',
        'namedetails': '1',
      },
    );

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Recherche de lieu impossible.');
    }

    final body = jsonDecode(response.body);
    if (body is! List) {
      return [];
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(PlaceModel.fromNominatim)
        .where((place) => place.name.trim().isNotEmpty)
        .toList();
  }

  Future<PlaceModel?> findNearestPlace({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(
      queryParameters: {
        'format': 'json',
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'zoom': '18',
        'addressdetails': '1',
        'namedetails': '1',
      },
    );

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Selection du lieu impossible.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> || body['error'] != null) {
      return null;
    }

    final place = PlaceModel.fromNominatim(body);
    if (place.name.trim().isEmpty) {
      return null;
    }

    return place;
  }
}
