import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/core/models/plant_model.dart';
import 'package:urban_green_mapper/core/models/adoption_model.dart';
import 'package:urban_green_mapper/features/adoption/providers/adoption_provider.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/utils/firestore_utils.dart';

class PlantCareScreen extends StatefulWidget {
  final String adoptionId;
  final String plantId;

  const PlantCareScreen({
    super.key,
    required this.adoptionId,
    required this.plantId,
  });

  @override
  State<PlantCareScreen> createState() => _PlantCareScreenState();
}

class _PlantCareScreenState extends State<PlantCareScreen> {
  final Map<String, bool> _careActivities = {
    'watering': false,
    'fertilizing': false,
    'pruning': false,
    'weeding': false,
    'pest_control': false,
    'mulching': false,
    'soil_check': false,
  };
  
  final _notesController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  
  AdoptionModel? _adoption;
  PlantModel? _plant;
  List<Map<String, dynamic>> _careHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      context.read<AdoptionProvider>();
      final firestore = FirebaseFirestore.instance;

      // Load adoption data directly from Firestore
      final adoptionDoc = await firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .doc(widget.adoptionId)
          .get();

      if (!adoptionDoc.exists) {
        throw Exception('Adoption record not found');
      }

      _adoption = AdoptionModel.fromMap(adoptionDoc.data()!);

      // Load plant data directly from Firestore
      final plantDoc = await firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(widget.plantId)
          .get();

      if (!plantDoc.exists) {
        throw Exception('Plant record not found');
      }

      _plant = PlantModel.fromMap(plantDoc.data()!);

      // Load care history
      final careHistorySnapshot = await firestore
          .collection(FirestoreConstants.careReportsCollection)
          .where('adoption_id', isEqualTo: widget.adoptionId)
          .orderBy('submitted_at', descending: true)
          .limit(5)
          .get();

      _careHistory = careHistorySnapshot.docs.map((doc) => doc.data()).toList();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading plant care data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load plant data: ${e.toString()}';
        });
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    final List<String> downloadUrls = [];
    final storage = FirebaseStorage.instance;

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final file = _selectedImages[i];
        final fileName = 'care_reports/${_adoption!.adoptionId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        final snapshot = await storage
            .ref()
            .child(fileName)
            .putFile(file);
        
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        
  debugPrint('✅ Care image uploaded: $downloadUrl');
      } catch (e) {
        debugPrint('❌ Error uploading care image: $e');
        // Continue with other images even if one fails
      }
    }

    return downloadUrls;
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint('Failed to take photo: $e');
      _showErrorSnackbar('Failed to take photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile?> images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(images.whereType<XFile>().map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      debugPrint('Failed to pick images: $e');
      _showErrorSnackbar('Failed to pick images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitCareReport() async {
    if (_adoption == null || _plant == null) {
      _showErrorSnackbar('Plant data not loaded properly');
      return;
    }

    // Validate form
    final selectedActivities = _careActivities.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedActivities.isEmpty) {
      _showErrorSnackbar('Please select at least one care activity');
      return;
    }

    if (_notesController.text.trim().isEmpty) {
      _showErrorSnackbar('Please add some notes about the care provided');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;

    if (currentUser == null) {
      _showErrorSnackbar('You need to be logged in to submit care reports');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Prepare care activities data
      final Map<String, dynamic> careActivities = {};
      for (final activity in selectedActivities) {
        careActivities[activity] = {
          'completed': true,
          'timestamp': DateTime.now().toIso8601String(),
          'description': _careDescriptions[activity] ?? activity,
        };
      }

      // Upload images to Firebase Storage
      final List<String> photoUrls = await _uploadImages();
      
      // Submit care report directly to Firestore
      final firestore = FirebaseFirestore.instance;
      final careReportId = 'care_${DateTime.now().millisecondsSinceEpoch}';

      await firestore
          .collection(FirestoreConstants.careReportsCollection)
          .doc(careReportId)
          .set({
            'care_report_id': careReportId,
            'adoption_id': _adoption!.adoptionId,
            'plant_id': _plant!.plantId,
            'user_id': currentUser.userId,
            'care_activities': careActivities,
            'notes': _notesController.text.trim(),
            'photo_urls': photoUrls,
            'submitted_at': DateTime.now().toIso8601String(),
            'status': 'submitted',
          });

      // Update adoption last care date
      await firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .doc(_adoption!.adoptionId)
          .update({
            'last_care_date': DateTime.now().toIso8601String(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update user impact score
      final userRef = firestore.collection(FirestoreConstants.usersCollection).doc(currentUser.userId);
      await firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          final currentScore = userDoc.data()!['impactScore'] ?? 0;
          final newScore = currentScore + 5;
          transaction.update(userRef, {
            'impactScore': newScore,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      });

      if (mounted) {
        _showSuccessSnackbar('Care report submitted successfully! 🎉');
        
        // Show impact points earned
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.yellow),
                SizedBox(width: 8),
                Text('+5 Impact Points earned for plant care!'),
              ],
            ),
            backgroundColor: Colors.green[800],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload data to show updated care history
        await _loadData();
        
        // Clear form
        _resetForm();
      }

    } catch (e) {
      debugPrint('❌ Error submitting care report: $e');
      if (mounted) {
        _showErrorSnackbar('Error submitting care report: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      // Reset care activities
      for (var key in _careActivities.keys) {
        _careActivities[key] = false;
      }
      // Clear images and notes
      _selectedImages.clear();
      _notesController.clear();
    });
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Care activity configurations
  final Map<String, String> _careDescriptions = {
    'watering': 'Added water to the plant',
    'fertilizing': 'Applied fertilizer to support growth',
    'pruning': 'Trimmed dead or overgrown branches',
    'weeding': 'Removed weeds around the plant',
    'pest_control': 'Treated for pests or diseases',
    'mulching': 'Added mulch to retain moisture',
    'soil_check': 'Checked soil quality and pH levels',
  };

  Map<String, String> _getActivityIcons() {
    return {
      'watering': '💧',
      'fertilizing': '🌱',
      'pruning': '✂️',
      'weeding': '🌿',
      'pest_control': '🐛',
      'mulching': '🍂',
      'soil_check': '🔄',
    };
  }

  Map<String, String> _getActivityTitles() {
    return {
      'watering': 'Watering',
      'fertilizing': 'Fertilizing',
      'pruning': 'Pruning',
      'weeding': 'Weeding',
      'pest_control': 'Pest Control',
      'mulching': 'Mulching',
      'soil_check': 'Soil Check',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_adoption == null || _plant == null) {
      return _buildErrorState();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Care for ${_plant!.species}'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading plant data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Care'),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                'Failed to Load',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Plant data not available',
                style: AppTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildCareForm(),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildCareForm(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildCareForm(),
        ),
      ),
    );
  }

  Widget _buildCareForm() {
    final activityIcons = _getActivityIcons();
    final activityTitles = _getActivityTitles();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plant Information Card
        _buildPlantInfoCard(),
        
        const SizedBox(height: 24),
        
        // Care History Section
        if (_careHistory.isNotEmpty) ...[
          _buildCareHistorySection(),
          const SizedBox(height: 24),
        ],
        
        // Care Activities Section
        Text(
          'Today\'s Care Activities',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all care activities you performed today',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        // Care Activities Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.0,
          ),
          itemCount: _careActivities.length,
          itemBuilder: (context, index) {
            final activityKey = _careActivities.keys.elementAt(index);
            final isSelected = _careActivities[activityKey] ?? false;
            
            return _buildActivityCard(
              activityKey,
              activityIcons[activityKey] ?? '🌿',
              activityTitles[activityKey] ?? activityKey,
              isSelected,
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Photos Section
        _buildPhotosSection(),
        
        const SizedBox(height: 24),
        
        // Notes Section
        Text(
          'Care Notes & Observations',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe the care you provided, plant health observations, any issues noticed, or additional comments...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Submit Button
        CustomButton(
          onPressed: _isSubmitting ? null : _submitCareReport,
          isLoading: _isSubmitting,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.health_and_safety, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Submit Care Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlantInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Plant Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: const DecorationImage(
                  image: AssetImage('assets/images/generic_plant.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Plant Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _plant!.species,
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'Adopted on ${_formatDate(_adoption!.adoptedAt)}',
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'Last care: ${_formatDate(_adoption!.lastCareDate)}',
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Health Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getHealthColor(_plant!.healthStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getHealthColor(_plant!.healthStatus),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          size: 14,
                          color: _getHealthColor(_plant!.healthStatus),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _plant!.healthStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getHealthColor(_plant!.healthStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Care History',
          style: AppTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _careHistory.length,
            itemBuilder: (context, index) {
              final report = _careHistory[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (() {
                        final dt = parseFirestoreDateTime(report['submitted_at']);
                        return dt != null ? _formatDate(dt) : '';
                      })(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        report['notes'] ?? 'No notes',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(String activityKey, String emoji, String title, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.green[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _careActivities[activityKey] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.green[800] : Colors.grey[700],
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Colors.green : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Plant Health',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add photos to document plant health and care activities (optional)',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        
        // Image Grid
        if (_selectedImages.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        
        // Photo Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getHealthColor(String healthStatus) {
    switch (healthStatus.toLowerCase()) {
      case 'excellent': return Colors.green;
      case 'good': return Colors.blue;
      case 'fair': return Colors.orange;
      case 'poor': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}