import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/place_controller.dart';
import '../../models/place_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PlacePickerView extends StatefulWidget {
  const PlacePickerView({super.key});

  @override
  State<PlacePickerView> createState() => _PlacePickerViewState();
}

class _PlacePickerViewState extends State<PlacePickerView> {
  final PlaceController _placeController = PlaceController();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final LatLng initialCenter = const LatLng(36.8065, 10.1815);

  List<PlaceModel> results = [];
  PlaceModel? selectedPlace;
  bool isSearching = false;
  bool isSelectingFromMap = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> searchPlaces() async {
    FocusScope.of(context).unfocus();
    setState(() => isSearching = true);

    try {
      final places = await _placeController.searchPlaces(
        _searchController.text,
      );
      if (!mounted) return;
      setState(() => results = places);
      if (places.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aucun lieu trouve.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) {
        setState(() => isSearching = false);
      }
    }
  }

  Future<void> selectNearestPlace(LatLng point) async {
    setState(() => isSelectingFromMap = true);

    try {
      final place = await _placeController.findNearestPlace(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      if (!mounted) return;
      if (place == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun lieu officiel trouve ici.')),
        );
        return;
      }
      selectPlace(place);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) {
        setState(() => isSelectingFromMap = false);
      }
    }
  }

  void selectPlace(PlaceModel place) {
    setState(() => selectedPlace = place);
    _mapController.move(LatLng(place.latitude, place.longitude), 16);
  }

  void confirmSelection() {
    final place = selectedPlace;
    if (place == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectionnez un lieu sur la carte.')),
      );
      return;
    }

    Navigator.pop(context, place);
  }

  @override
  Widget build(BuildContext context) {
    final marker = selectedPlace == null
        ? null
        : Marker(
            point: LatLng(selectedPlace!.latitude, selectedPlace!.longitude),
            width: 44,
            height: 44,
            child: const Icon(
              Icons.location_on,
              color: AppTheme.error,
              size: 42,
            ),
          );

    return AppScaffold(
      title: 'Choisir un lieu',
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _searchController,
                  label: 'Rechercher un lieu',
                  hintText: 'Stade, theatre, restaurant...',
                  icon: Icons.search,
                  textInputAction: TextInputAction.search,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 56,
                child: IconButton.filled(
                  tooltip: 'Rechercher',
                  onPressed: isSearching ? null : searchPlaces,
                  icon: isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 330,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 12,
                  onTap: (_, point) => selectNearestPlace(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.devmob_developpement',
                  ),
                  if (marker != null) MarkerLayer(markers: [marker]),
                ],
              ),
            ),
          ),
          if (isSelectingFromMap) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 12),
          if (selectedPlace != null) _SelectedPlaceCard(place: selectedPlace!),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Resultats',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final place in results) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(place.name),
                  subtitle: Text(
                    place.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => selectPlace(place),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 16),
          CustomButton(
            label: 'Valider ce lieu',
            icon: Icons.check_circle_outline,
            onPressed: selectedPlace == null ? null : confirmSelection,
          ),
        ],
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  final PlaceModel place;

  const _SelectedPlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
