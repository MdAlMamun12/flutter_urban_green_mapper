import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';

class CreateEventDialog extends StatefulWidget {
  final Function(EventModel) onEventCreated;

  const CreateEventDialog({super.key, required this.onEventCreated});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  DateTime _startTime = DateTime.now().add(const Duration(days: 1));
  DateTime? _endTime;
  List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return AlertDialog(
      title: const Text('Create New Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Start: ${_startTime.toString()}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectStartTime(),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _maxParticipantsController,
                decoration: const InputDecoration(labelText: 'Max Participants'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max participants';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(labelText: 'Contact Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _createEvent(user?.userId ?? ''),
          child: const Text('Create Event'),
        ),
      ],
    );
  }

  Future<void> _selectStartTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _createEvent(String ngoId) {
    if (_formKey.currentState!.validate()) {
      final event = EventModel(
        eventId: DateTime.now().millisecondsSinceEpoch.toString(),
        ngoId: ngoId,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        startTime: _startTime,
        endTime: _endTime,
        maxParticipants: int.parse(_maxParticipantsController.text),
        currentParticipants: 0,
        status: 'upcoming',
        contactEmail: _contactEmailController.text,
        contactPhone: _contactPhoneController.text,
        tags: _tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onEventCreated(event);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }
}