import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/mapping/providers/map_provider.dart';
import 'package:urban_green_mapper/features/mapping/screens/report_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize map data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MapProvider>(context, listen: false).loadGreenSpaces();
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
        // Map view would go here (using Google Maps or Mapbox)
        _buildMapPlaceholder(),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildSearchBar(),
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