import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/adoption/providers/adoption_provider.dart';
import 'package:urban_green_mapper/core/models/plant_model.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdoptionProvider>().loadPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopt a Plant'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdoptionProvider>().loadPlants();
            },
          ),
        ],
      ),
      body: Consumer<AdoptionProvider>(
        builder: (context, adoptionProvider, child) {
          if (adoptionProvider.error != null) {
            return _buildErrorWidget(adoptionProvider.error!);
          }

          if (adoptionProvider.plants.isEmpty && !adoptionProvider.isLoading) {
            return _buildEmptyWidget();
          }

          return ResponsiveLayout(
            mobile: _buildMobileLayout(adoptionProvider),
            tablet: _buildTabletLayout(adoptionProvider),
            desktop: _buildDesktopLayout(adoptionProvider),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(AdoptionProvider adoptionProvider) {
    if (adoptionProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adoptionProvider.plants.length,
      itemBuilder: (context, index) {
        final plant = adoptionProvider.plants[index];
        return _buildPlantCard(plant, context);
      },
    );
  }

  Widget _buildTabletLayout(AdoptionProvider adoptionProvider) {
    if (adoptionProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: adoptionProvider.plants.length,
      itemBuilder: (context, index) {
        final plant = adoptionProvider.plants[index];
        return _buildPlantCard(plant, context);
      },
    );
  }

  Widget _buildDesktopLayout(AdoptionProvider adoptionProvider) {
    if (adoptionProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: adoptionProvider.plants.length,
      itemBuilder: (context, index) {
        final plant = adoptionProvider.plants[index];
        return _buildPlantCard(plant, context);
      },
    );
  }

  Widget _buildPlantCard(PlantModel plant, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: AssetImage(_getPlantImage(plant.species)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            size: 14,
                            color: _getHealthColor(plant.healthStatus),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            plant.healthStatus.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.species,
                        style: AppTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Planted on ${_formatDate(plant.plantingDate)}',
                        style: AppTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (plant.spaceId.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Space ID: ${plant.spaceId}',
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  CustomButton(
                    onPressed: () {
                      _showAdoptionDialog(plant, context);
                    },
                    child: const Text('Adopt This Plant'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Plants',
            style: AppTheme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: AppTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              context.read<AdoptionProvider>().loadPlants();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nature_outlined,
            size: 64,
            color: Colors.green[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Plants Available',
            style: AppTheme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new plants to adopt!',
            style: AppTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPlantImage(String species) {
    // Default plant images - you can add these to your assets
    if (species.toLowerCase().contains('oak')) {
      return 'assets/images/oak_tree.jpg';
    } else if (species.toLowerCase().contains('maple')) {
      return 'assets/images/maple_tree.jpg';
    } else if (species.toLowerCase().contains('pine')) {
      return 'assets/images/pine_tree.jpg';
    } else if (species.toLowerCase().contains('rose')) {
      return 'assets/images/rose.jpg';
    } else if (species.toLowerCase().contains('tulip')) {
      return 'assets/images/tulip.jpg';
    } else {
      return 'assets/images/generic_plant.jpg';
    }
  }

  Color _getHealthColor(String healthStatus) {
    switch (healthStatus.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAdoptionDialog(PlantModel plant, BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;
    
    if (currentUser == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adopt This Plant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to adopt this ${plant.species}?',
                style: AppTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'By adopting this plant, you agree to:',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildAdoptionRequirement('Regular watering and care'),
              _buildAdoptionRequirement('Monitoring plant health'),
              _buildAdoptionRequirement('Reporting any issues'),
              _buildAdoptionRequirement('Following care schedule'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _adoptPlant(plant, context);
                Navigator.pop(context);
              },
              child: const Text('Adopt Plant'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdoptionRequirement(String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requirement,
              style: AppTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to be logged in to adopt a plant.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to login screen
                // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _adoptPlant(PlantModel plant, BuildContext context) async {
    final adoptionProvider = context.read<AdoptionProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;
    
    if (currentUser == null) return;

    try {
      final success = await adoptionProvider.adoptPlant(plant.plantId, currentUser.userId);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully adopted the ${plant.species}!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to adopt plant: ${adoptionProvider.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to adopt plant: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}