import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/dashboard_provider.dart';
import 'package:urban_green_mapper/features/reports/providers/report_provider.dart';
import 'package:urban_green_mapper/core/models/green_space_model.dart';
import 'package:urban_green_mapper/features/mapping/screens/map_screen.dart';

class ReportScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const ReportScreen({super.key, this.initialLocation});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedReportType = 'Maintenance Needed';
  String? _selectedSpaceId;
  final List<String> _imagePaths = [];
  
  final List<String> _reportTypes = [
    'Maintenance Needed',
    'Vandalism Report',
    'Safety Concern',
    'Improvement Suggestion',
    'Other Issue',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load green spaces when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dashboardProvider = context.read<DashboardProvider>();
      await dashboardProvider.loadDashboardData();

      // If opened from the map with an initial location, try to pre-select the nearest space
      if (widget.initialLocation != null) {
        final loc = widget.initialLocation!;
        double minDist = double.infinity;
        dynamic nearest;
        for (final space in dashboardProvider.nearbySpaces) {
          if (space.latitude == null || space.longitude == null) continue;
          final d = geo.Geolocator.distanceBetween(
            loc.latitude,
            loc.longitude,
            space.latitude!,
            space.longitude!,
          );
          if (d < minDist) {
            minDist = d;
            nearest = space;
          }
        }
        if (nearest != null) {
          setState(() {
            _selectedSpaceId = nearest.spaceId;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile?> images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _imagePaths.addAll(images.whereType<XFile>().map((xfile) => xfile.path));
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpaceId == null) {
      _showErrorDialog('Please select a green space');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final reportProvider = context.read<ReportProvider>();

    final user = authProvider.user;
    if (user == null) {
      _showErrorDialog('Please login to submit a report');
      return;
    }

    // Get selected space
    final selectedSpace = dashboardProvider.nearbySpaces
        .firstWhere((space) => space.spaceId == _selectedSpaceId);
    
    // Generate title if not provided
    final title = _titleController.text.isNotEmpty 
        ? _titleController.text 
        : '$_selectedReportType - ${selectedSpace.name}';
    
    // Submit report with image paths
    final success = await reportProvider.submitReport(
      title: title,
      description: _descriptionController.text,
      reportType: _selectedReportType,
      spaceId: _selectedSpaceId!,
      spaceName: selectedSpace.name,
      imagePaths: _imagePaths,
      userId: user.userId,
      userName: user.name,
    );

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      _showErrorDialog(reportProvider.error ?? 'Failed to submit report');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Report Submitted'),
          ],
        ),
        content: const Text('Thank you for your report! We will review it and take appropriate action.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Submission Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedReportType = 'Maintenance Needed';
      _selectedSpaceId = null;
      _imagePaths.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final reportProvider = context.watch<ReportProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Green Space'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              dashboardProvider.loadDashboardData();
              reportProvider.clearError();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header
              _buildHeaderSection(),
              const SizedBox(height: 24),

              // Report Title
              _buildTitleSection(),
              const SizedBox(height: 20),

              // Report Type
              _buildReportTypeSection(),
              const SizedBox(height: 20),

              // Green Space Selection
              _buildSpaceSelectionSection(dashboardProvider),
              const SizedBox(height: 20),

              // Description
              _buildDescriptionSection(),
              const SizedBox(height: 20),

              // Photos
              _buildPhotosSection(),
              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(reportProvider, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Green Space',
          style: AppTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help us maintain and improve our green spaces by reporting issues or suggestions',
          style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Title (Optional)',
          style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Broken Bench at Central Park',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildReportTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Type *',
          style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reportTypes.map((type) {
            final isSelected = _selectedReportType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedReportType = type;
                });
              },
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpaceSelectionSection(DashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Green Space *',
          style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSpaceId,
              isExpanded: true,
              hint: const Text('Choose a green space'),
              items: dashboardProvider.nearbySpaces.map((space) {
                return DropdownMenuItem<String>(
                  value: space.spaceId,
                  child: Text(space.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSpaceId = newValue;
                });
              },
            ),
          ),
        ),
        if (dashboardProvider.nearbySpaces.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'No green spaces available. Please check your location settings.',
            style: TextStyle(color: Colors.orange[700], fontSize: 12),
          ),
        ],
        // Selected space preview
        if (_selectedSpaceId != null) ...[
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final matches = dashboardProvider.nearbySpaces.where((s) => s.spaceId == _selectedSpaceId).toList();
            if (matches.isEmpty) return const SizedBox.shrink();
            final selected = matches.first;
            return Card(
              color: Colors.green[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: Icon(_getSpaceIcon(selected.type), color: Colors.green[700]),
                title: Text(selected.name, style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('${selected.type} • ${_getDistanceText(selected)}', style: AppTheme.textTheme.bodySmall),
                trailing: IconButton(
                  icon: const Icon(Icons.map, color: Colors.green),
                  onPressed: () {
                    // Open full map to show this space
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
                  },
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe the issue or suggestion in detail...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters long';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${_imagePaths.length}/5)',
          style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Add photos to help us understand the issue better (max 5 photos)',
          style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        // Image Grid
        if (_imagePaths.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _imagePaths.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(_imagePaths[index])),
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
                          size: 16,
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
        ] else ...[
          const SizedBox(height: 12),
        ],

        // If no photos yet, show a helpful placeholder
        if (_imagePaths.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.photo_camera_outlined, size: 36, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add photos to make your report clearer. Show damaged areas, location markers, or any evidence.',
                    style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],

        // Photo Buttons
        if (_imagePaths.length < 5) ...[
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
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maximum 5 photos reached. Remove some to add more.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(ReportProvider reportProvider, AuthProvider authProvider) {
    return Column(
      children: [
        if (reportProvider.error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reportProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: reportProvider.clearError,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (reportProvider.isLoading) ...[
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Submitting report...'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton(
                onPressed: reportProvider.isLoading ? null : _submitReport,
                isLoading: reportProvider.isLoading,
                child: const Text('Submit Report'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: reportProvider.isLoading ? null : _clearForm,
                child: const Text('Clear'),
              ),
            ),
          ],
        ),

        if (authProvider.user == null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You need to be logged in to submit a report',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  IconData _getSpaceIcon(String type) {
    switch (type.toLowerCase()) {
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

  String _getDistanceText(GreenSpaceModel space) {
    try {
      if (space.latitude == null || space.longitude == null) return 'Location unknown';
      if (widget.initialLocation != null) {
        final d = geo.Geolocator.distanceBetween(
          widget.initialLocation!.latitude,
          widget.initialLocation!.longitude,
          space.latitude!,
          space.longitude!,
        );
        if (d < 1000) return '${d.toStringAsFixed(0)} m';
        return '${(d / 1000).toStringAsFixed(1)} km';
      }
    } catch (_) {
      // ignore and fallthrough
    }
    return 'Distance unknown';
  }
}