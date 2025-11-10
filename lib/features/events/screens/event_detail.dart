import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/events/providers/events_provider.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetail extends StatefulWidget {
  final EventModel event;

  const EventDetail({super.key, required this.event});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  bool _isJoining = false;
  bool _isLeaving = false;
  bool _isCheckingParticipation = true;
  bool _isUserParticipating = false;

  @override
  void initState() {
    super.initState();
    _checkUserParticipation();
  }

  Future<void> _checkUserParticipation() async {
    try {
      // In a real app, this would use the current user's ID from AuthProvider
      final String userId = 'user123'; // Replace with actual user ID
      final isParticipating = await Provider.of<EventsProvider>(context, listen: false)
          .isUserParticipating(widget.event.eventId, userId);
      
      setState(() {
        _isUserParticipating = isParticipating;
        _isCheckingParticipation = false;
      });
    } catch (e) {
      print('Error checking participation: $e');
      setState(() {
        _isCheckingParticipation = false;
      });
    }
  }

  Future<void> _joinEvent() async {
    setState(() => _isJoining = true);
    
    try {
      final String userId = 'user123'; // Replace with actual user ID
      await Provider.of<EventsProvider>(context, listen: false)
          .joinEvent(widget.event.eventId, userId);
      
      setState(() {
        _isUserParticipating = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the event!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  Future<void> _leaveEvent() async {
    setState(() => _isLeaving = true);
    
    try {
      final String userId = 'user123'; // Replace with actual user ID
      await Provider.of<EventsProvider>(context, listen: false)
          .leaveEvent(widget.event.eventId, userId);
      
      setState(() {
        _isUserParticipating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have left the event.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLeaving = false);
    }
  }

  Future<void> _contactOrganizer(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Regarding: ${widget.event.title}',
        'body': 'Hello, I would like to know more about your event "${widget.event.title}".',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app')),
      );
    }
  }

  Future<void> _callOrganizer(String phone) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
            tooltip: 'Share Event',
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

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventImage(),
          const SizedBox(height: 16),
          _buildEventHeader(),
          const SizedBox(height: 16),
          _buildEventDetails(),
          const SizedBox(height: 24),
          _buildContactInfo(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventImage(),
          const SizedBox(height: 24),
          _buildEventHeader(),
          const SizedBox(height: 24),
          _buildEventDetails(),
          const SizedBox(height: 32),
          _buildContactInfo(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: SizedBox(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventImage(),
              const SizedBox(height: 24),
              _buildEventHeader(),
              const SizedBox(height: 24),
              _buildEventDetails(),
              const SizedBox(height: 32),
              _buildContactInfo(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        image: widget.event.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(widget.event.imageUrl!),
                fit: BoxFit.cover,
              )
            : const DecorationImage(
                image: AssetImage('assets/images/event_placeholder.jpg'),
                fit: BoxFit.cover,
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Chip(
              label: Text(
                widget.event.statusText.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: _getStatusColor(widget.event.status),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event.title,
          style: AppTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 8),
        if (widget.event.tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.event.tags
                .map((tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.green[50],
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          widget.event.description,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Details',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.calendar_today,
              label: 'Date & Time',
              value: '${widget.event.formattedDateTime}',
              subtitle: widget.event.endTime != null 
                  ? 'Duration: ${widget.event.durationText}'
                  : null,
            ),
            _buildDetailItem(
              icon: Icons.location_on,
              label: 'Location',
              value: widget.event.location,
              subtitle: widget.event.hasLocationCoordinates 
                  ? 'View on Map'
                  : null,
            ),
            _buildDetailItem(
              icon: Icons.people,
              label: 'Participants',
              value: widget.event.participantsText,
              subtitle: '${widget.event.remainingSpots} spots remaining',
            ),
            if (widget.event.requirements != null && widget.event.requirements!.isNotEmpty) ...[
              _buildDetailItem(
                icon: Icons.checklist,
                label: 'Requirements',
                value: widget.event.requirements!,
              ),
            ],
            if (widget.event.budget != null) ...[
              _buildDetailItem(
                icon: Icons.attach_money,
                label: 'Budget',
                value: '\$${widget.event.budget!.toStringAsFixed(2)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.green[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.textTheme.bodyMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            if (widget.event.contactEmail.isNotEmpty) ...[
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.email, size: 20, color: Colors.blue),
                ),
                title: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.event.contactEmail),
                trailing: IconButton(
                  icon: const Icon(Icons.email, color: Colors.blue),
                  onPressed: () => _contactOrganizer(widget.event.contactEmail),
                ),
              ),
              const Divider(),
            ],
            if (widget.event.contactPhone.isNotEmpty) ...[
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, size: 20, color: Colors.green),
                ),
                title: const Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.event.contactPhone),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _callOrganizer(widget.event.contactPhone),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isCheckingParticipation) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        if (widget.event.canJoin && !_isUserParticipating) ...[
          CustomButton(
            onPressed: _isJoining ? null : _joinEvent,
            width: double.infinity,
            child: _isJoining
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Joining...'),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, size: 20),
                      SizedBox(width: 8),
                      Text('Join Event'),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
        ],

        if (_isUserParticipating) ...[
          CustomButton(
            onPressed: _isLeaving ? null : _leaveEvent,
            width: double.infinity,
            backgroundColor: Colors.orange,
            child: _isLeaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Leaving...'),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_remove, size: 20),
                      SizedBox(width: 8),
                      Text('Leave Event'),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are participating in this event',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (widget.event.isFull && !_isUserParticipating) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This event is full',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (widget.event.isCompleted) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This event has been completed',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (widget.event.isCancelled) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This event has been cancelled',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _shareEvent() {
    // Implement share functionality
    final shareText = 'Check out this event: ${widget.event.title}\n\n'
        '${widget.event.description}\n\n'
        'Date: ${widget.event.formattedDateTime}\n'
        'Location: ${widget.event.location}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: $shareText'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}