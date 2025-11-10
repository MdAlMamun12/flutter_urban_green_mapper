import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/core/widgets/custom_text_field.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/events/providers/events_provider.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _photos = [];
  
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    
    try {
      // Combine date and time
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      
      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Create event data map
      final eventData = {
        'eventId': DateTime.now().millisecondsSinceEpoch.toString(),
        'ngoId': 'current_ngo_id', // This would come from auth in a real app
        'title': _titleController.text,
        'description': _descriptionController.text,
        'startTime': startDateTime,
        'endTime': endDateTime,
        'maxParticipants': int.parse(_maxParticipantsController.text),
        'status': 'upcoming',
        'location': _locationController.text,
        'createdAt': DateTime.now(),
      };

      // Create event using the provider
      await eventsProvider.createEvent(eventData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<EventsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(eventsProvider),
        tablet: _buildTabletLayout(eventsProvider),
        desktop: _buildDesktopLayout(eventsProvider),
      ),
    );
  }

  Widget _buildMobileLayout(EventsProvider eventsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildForm(eventsProvider),
    );
  }

  Widget _buildTabletLayout(EventsProvider eventsProvider) {
    return Center(
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildForm(eventsProvider),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(EventsProvider eventsProvider) {
    return Center(
      child: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildForm(eventsProvider),
        ),
      ),
    );
  }

  Widget _buildForm(EventsProvider eventsProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create New Event',
            style: AppTheme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _titleController,
            labelText: 'Event Title',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter event title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _descriptionController,
            labelText: 'Description',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter event description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _maxParticipantsController,
            labelText: 'Maximum Participants',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter maximum participants';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _locationController,
            labelText: 'Location',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter event location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDateTimeSection(),
          const SizedBox(height: 16),
          _buildPhotoSection(),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: eventsProvider.isLoading ? null : _createEvent,
            child: eventsProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date & Time',
          style: AppTheme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDate(context, true),
                child: Text(
                  _startDate != null
                      ? _formatDate(_startDate!)
                      : 'Select Start Date',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectTime(context, true),
                child: Text(
                  _startTime != null
                      ? _startTime!.format(context)
                      : 'Select Start Time',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDate(context, false),
                child: Text(
                  _endDate != null
                      ? _formatDate(_endDate!)
                      : 'Select End Date',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectTime(context, false),
                child: Text(
                  _endTime != null
                      ? _endTime!.format(context)
                      : 'Select End Time',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Photos',
          style: AppTheme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._photos.map((photo) => _buildPhotoThumbnail(photo)),
            _buildAddPhotoButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(String photoPath) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: Icon(Icons.photo, size: 40, color: Colors.grey[600]),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
            onPressed: () {
              setState(() {
                _photos.remove(photoPath);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}