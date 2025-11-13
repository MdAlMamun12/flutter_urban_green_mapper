import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/features/dashboard/utils/dashboard_colors.dart';

class VolunteerInvitationScreen extends StatefulWidget {
  const VolunteerInvitationScreen({super.key});

  @override
  State<VolunteerInvitationScreen> createState() => _VolunteerInvitationScreenState();
}

class _VolunteerInvitationScreenState extends State<VolunteerInvitationScreen> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedEventId;
  final List<String> _emails = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NGODashboardProvider>(context, listen: false);
      provider.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<NGODashboardProvider>(context);
    final upcomingEvents = dashboardProvider.events.where((event) => 
        event.status == 'upcoming' || event.status == 'ongoing').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Volunteers'),
        backgroundColor: DashboardColors.safeGreen(700),
        foregroundColor: DashboardColors.primaryWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Event',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildEventDropdown(upcomingEvents),
            const SizedBox(height: 24),
            Text(
              'Invite Volunteers',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildEmailInput(),
            const SizedBox(height: 16),
            _buildEmailList(),
            const SizedBox(height: 24),
            Text(
              'Invitation Message',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMessageInput(),
            const SizedBox(height: 24),
            _buildSendButton(dashboardProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDropdown(List<EventModel> events) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedEventId,
              decoration: const InputDecoration(
                labelText: 'Select Event',
                border: OutlineInputBorder(),
              ),
              items: events.map((event) {
                return DropdownMenuItem(
                  value: event.eventId,
                  child: Text(event.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEventId = value;
                });
              },
            ),
            if (_selectedEventId != null) ...[
              const SizedBox(height: 12),
              Text(
                'Selected Event: ${events.firstWhere((e) => e.eventId == _selectedEventId).title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      hintText: 'Enter volunteer email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addEmail,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add multiple email addresses to invite multiple volunteers',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailList() {
    if (_emails.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DashboardColors.safeGrey(50),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No emails added yet',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: DashboardColors.safeGrey(500),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volunteers to Invite (${_emails.length})',
              style: AppTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._emails.map((email) => _buildEmailItem(email)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailItem(String email) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.safeGreen(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.safeGreen(100)),
      ),
      child: Row(
        children: [
          Icon(Icons.email, size: 16, color: DashboardColors.safeGreen(700)),
          const SizedBox(width: 8),
          Expanded(child: Text(email)),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => _removeEmail(email),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'Invitation Message',
            border: OutlineInputBorder(),
            hintText: 'Write a personalized message for your volunteers...',
          ),
          maxLines: 5,
        ),
      ),
    );
  }

  Widget _buildSendButton(NGODashboardProvider provider) {
    final isEnabled = _selectedEventId != null && _emails.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: isEnabled ? () => _sendInvitations(provider) : null,
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(DashboardColors.primaryWhite),
                ),
              )
            : const Text('Send Invitations'),
      ),
    );
  }

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: DashboardColors.primaryRed,
        ),
      );
      return;
    }

    if (_emails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already added'),
          backgroundColor: DashboardColors.primaryOrange,
        ),
      );
      return;
    }

    setState(() {
      _emails.add(email);
      _emailController.clear();
    });
  }

  void _removeEmail(String email) {
    setState(() {
      _emails.remove(email);
    });
  }

  void _sendInvitations(NGODashboardProvider provider) async {
    try {
      await provider.inviteVolunteers(
        _selectedEventId!,
        _emails,
        _messageController.text.trim().isEmpty 
            ? 'You have been invited to volunteer for our environmental initiative. We would love to have you join us!'
            : _messageController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitations sent to ${_emails.length} volunteers'),
          backgroundColor: DashboardColors.primaryGreen,
        ),
      );

      // Clear form
      setState(() {
        _emails.clear();
        _messageController.clear();
        _selectedEventId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send invitations: $e'),
          backgroundColor: DashboardColors.primaryRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}