import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import 'custom_button.dart';

class LocationMapCard extends StatelessWidget {
  final String placeName;
  final double latitude;
  final double longitude;

  const LocationMapCard({
    super.key,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  Future<void> openInGoogleMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d ouvrir Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lieu',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(placeName, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.devmob_developpement',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_on,
                            color: AppTheme.error,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Ouvrir dans Google Maps',
              icon: Icons.map_outlined,
              outlined: true,
              onPressed: () => openInGoogleMaps(context),
            ),
          ],
        ),
      ),
    );
  }
}
