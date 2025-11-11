import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/mapping/providers/map_provider.dart';
import 'package:urban_green_mapper/features/mapping/screens/report_screen.dart';
import 'package:urban_green_mapper/features/events/providers/events_provider.dart';
import 'package:urban_green_mapper/features/events/screens/event_detail.dart';
import 'package:urban_green_mapper/core/services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  bool _mapReady = false;
  @override
  void initState() {
    super.initState();
    // Initialize map data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MapProvider>(context, listen: false).loadGreenSpaces();
      // Initialize location service (permissions)
      _locationService.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to report screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _buildGoogleMap(),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildSearchBar(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: _goToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildMapPlaceholder(),
        ),
        Expanded(
          flex: 1,
          child: _buildSidePanel(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildMapPlaceholder(),
        ),
        Expanded(
          flex: 1,
          child: _buildSidePanel(),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Map View',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Green spaces would be displayed here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    // If running on web and google maps JS API not configured, avoid creating the
    // GoogleMap widget which can throw JS errors like "MapTypeId is undefined".
    if (kIsWeb) {
      return _buildWebMapFallback();
    }
    final initialPosition = CameraPosition(
      target: const LatLng(40.7128, -74.0060),
      zoom: 12,
    );

    return Consumer<MapProvider>(builder: (context, provider, child) {
      // Build markers from provider data
      _markers.clear();
      for (final space in provider.greenSpaces) {
        if (space.latitude == null || space.longitude == null) continue;
        _markers.add(Marker(
          markerId: MarkerId(space.spaceId),
          position: LatLng(space.latitude!, space.longitude!),
          infoWindow: InfoWindow(
            title: space.name,
            snippet: '${space.type} • ${space.statusText}',
            onTap: () async {
              // Select the space and open details
              provider.selectSpace(space);
              // Optionally navigate to a detail or open bottom sheet
              _showSpaceBottomSheet(space);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _markerHueForStatus(space.status),
          ),
        ));
      }

      // Also add event markers (different hue) when available
      try {
        final eventsProv = Provider.of<EventsProvider>(context, listen: false);
        if (eventsProv.events.isNotEmpty) {
          for (final ev in eventsProv.events) {
            if (ev.latitude == null || ev.longitude == null) continue;
            _markers.add(Marker(
              markerId: MarkerId('event_${ev.eventId}'),
              position: LatLng(ev.latitude!, ev.longitude!),
              infoWindow: InfoWindow(
                title: ev.title,
                snippet: ev.formattedDate,
                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetail(event: ev)));
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ));
          }
        }
      } catch (_) {
        // ignore if events provider not present
      }

      return GoogleMap(
        initialCameraPosition: initialPosition,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;
          _mapReady = true;
        },
        onCameraIdle: () async {
          if (!_mapReady) return;
          try {
            final bounds = await _mapController.getVisibleRegion();
            final north = bounds.northeast.latitude;
            final east = bounds.northeast.longitude;
            final south = bounds.southwest.latitude;
            final west = bounds.southwest.longitude;
            // Load green spaces in bounds (provider may do geospatial filtering)
            provider.loadGreenSpacesInBounds(north, south, east, west);
          } catch (e) {
            // ignore errors from getVisibleRegion in unsupported environments
          }
        },
        onTap: (latLng) {
          // Allow reporting a new green space at tapped location
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportScreen(initialLocation: latLng),
            ),
          );
        },
      );
    });
  }

  Widget _buildWebMapFallback() {
    // On web, if the Google Maps JS SDK isn't loaded (no API key in index.html),
    // creating the GoogleMap widget can lead to JS runtime errors (MapTypeId undefined).
    // Show a friendly fallback with a list of green spaces and events instead.
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    EventsProvider? eventsProvider;
    try {
      eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    } catch (_) {
      eventsProvider = null;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Card(
            color: Color(0xFF8B0000),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Map is not available on web without Google Maps API key configured in web/index.html.\nAdd the Maps JS script with your API key or run on mobile/device.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Green spaces', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...mapProvider.greenSpaces.map((space) => ListTile(
                title: Text(space.name),
                subtitle: Text(space.type),
              )),
          const SizedBox(height: 12),
          Text('Events', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // eventsProvider may be EventsProvider; guard if not available
          if (eventsProvider != null && eventsProvider.events.isNotEmpty) ...[
            ...eventsProvider.events.map((e) => ListTile(title: Text(e.title), subtitle: Text(e.formattedDate))).toList()
          ] else ...[
            const Text('No events available'),
          ],
        ],
      ),
    );
  }

  double _markerHueForStatus(String status) {
    switch (status) {
      case 'healthy':
        return BitmapDescriptor.hueGreen;
      case 'degraded':
        return BitmapDescriptor.hueOrange;
      case 'restored':
        return BitmapDescriptor.hueAzure;
      case 'critical':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  void _showSpaceBottomSheet(dynamic space) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(space.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(space.description ?? ''),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to full detail page if exists
                    },
                    child: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Start report flow pre-filled
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportScreen()),
                      );
                    },
                    child: const Text('Report Issue'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final pos = await _locationService.getLocationWithFallback();
      final target = LatLng(pos.latitude, pos.longitude);
      if (_mapReady) {
        await _mapController.animateCamera(CameraUpdate.newLatLngZoom(target, 15));
      }
    } catch (e) {
      // ignore
    }
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search for green spaces...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        if (mapProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Nearby Green Spaces',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...mapProvider.greenSpaces.map((space) => _buildSpaceCard(space)),
          ],
        );
      },
    );
  }

  Widget _buildSpaceCard(dynamic space) {
    return Card(
      child: ListTile(
        leading: Icon(
          _getSpaceIcon(space.type),
          color: _getStatusColor(space.status),
        ),
        title: Text(space.name),
        subtitle: Text('${space.type} • ${space.status}'),
        onTap: () {
          // Zoom to this space on the map
        },
      ),
    );
  }

  IconData _getSpaceIcon(String type) {
    switch (type) {
      case 'park':
        return Icons.park;
      case 'garden':
        return Icons.local_florist;
      case 'forest':
        return Icons.forest;
      default:
        return Icons.nature;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'healthy':
        return Colors.green;
      case 'degraded':
        return Colors.orange;
      case 'restored':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}