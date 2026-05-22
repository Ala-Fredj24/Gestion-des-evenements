class PlaceModel {
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;

  const PlaceModel({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceModel.fromNominatim(Map<String, dynamic> map) {
    final displayName = (map['display_name'] ?? '').toString();
    final namedetails = map['namedetails'];
    final officialName = namedetails is Map
        ? (namedetails['name'] ?? namedetails['official_name'] ?? '').toString()
        : '';
    final fallbackName = (map['name'] ?? '').toString();
    final firstDisplayPart = displayName.split(',').first.trim();

    return PlaceModel(
      name: officialName.trim().isNotEmpty
          ? officialName.trim()
          : fallbackName.trim().isNotEmpty
          ? fallbackName.trim()
          : firstDisplayPart,
      displayName: displayName,
      latitude: double.tryParse((map['lat'] ?? '').toString()) ?? 0,
      longitude: double.tryParse((map['lon'] ?? '').toString()) ?? 0,
    );
  }
}
