import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';

class EventsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all events
  Future<void> loadEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final eventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .orderBy('start_time', descending: false)
          .get();

      _events = eventsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['event_id'] = doc.id; // Ensure event_id is set
        return EventModel.fromMap(data);
      }).toList();

      print('✅ Loaded ${_events.length} events');

    } catch (e) {
      _error = 'Failed to load events: $e';
      print('❌ Error loading events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new event
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Generate a unique event ID if not provided
      final eventId = eventData['eventId'] ?? _firestore.collection(FirestoreConstants.eventsCollection).doc().id;
      final now = DateTime.now();

      // Create EventModel from the data with all required parameters
      final event = EventModel(
        eventId: eventId,
        ngoId: eventData['ngoId'] ?? '',
        title: eventData['title'] ?? '',
        description: eventData['description'] ?? '',
        location: eventData['location'] ?? '',
        startTime: eventData['startTime'] is DateTime ? eventData['startTime'] : DateTime.now(),
        endTime: eventData['endTime'] is DateTime ? eventData['endTime'] : null,
        maxParticipants: eventData['maxParticipants'] is int ? eventData['maxParticipants'] : 0,
        currentParticipants: eventData['currentParticipants'] is int ? eventData['currentParticipants'] : 0,
        status: eventData['status'] ?? 'upcoming',
        createdAt: eventData['createdAt'] is DateTime ? eventData['createdAt'] : now,
        updatedAt: eventData['updatedAt'] is DateTime ? eventData['updatedAt'] : now,
        participants: List<String>.from(eventData['participants'] ?? []),
        tags: List<String>.from(eventData['tags'] ?? []),
        imageUrl: eventData['imageUrl'],
        latitude: eventData['latitude']?.toDouble(),
        longitude: eventData['longitude']?.toDouble(),
        contactEmail: eventData['contactEmail'] ?? '',
        contactPhone: eventData['contactPhone'] ?? '',
        budget: eventData['budget']?.toDouble(),
        requirements: eventData['requirements'],
      );

      // Validate the event
      final validationErrors = event.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception('Event validation failed: ${validationErrors.join(', ')}');
      }

      // Use DatabaseService to create the event
      await _databaseService.createEvent(event);

      // Add to local list
      _events.add(event);
      
      print('✅ Event created successfully: ${event.title}');

    } catch (e) {
      _error = 'Failed to create event: $e';
      print('❌ Error creating event: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get events by NGO
  Future<void> loadEventsByNGO(String ngoId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final eventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .where('ngo_id', isEqualTo: ngoId)
          .orderBy('start_time', descending: true)
          .get();

      _events = eventsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['event_id'] = doc.id;
        return EventModel.fromMap(data);
      }).toList();

      print('✅ Loaded ${_events.length} events for NGO: $ngoId');

    } catch (e) {
      _error = 'Failed to load NGO events: $e';
      print('❌ Error loading NGO events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get upcoming events
  Future<void> loadUpcomingEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final eventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .where('start_time', isGreaterThanOrEqualTo: now)
          .where('status', isEqualTo: 'upcoming')
          .orderBy('start_time', descending: false)
          .get();

      _events = eventsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['event_id'] = doc.id;
        return EventModel.fromMap(data);
      }).toList();

      print('✅ Loaded ${_events.length} upcoming events');

    } catch (e) {
      _error = 'Failed to load upcoming events: $e';
      print('❌ Error loading upcoming events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get ongoing events
  Future<void> loadOngoingEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final eventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .where('start_time', isLessThanOrEqualTo: now)
          .where('end_time', isGreaterThanOrEqualTo: now)
          .where('status', isEqualTo: 'ongoing')
          .orderBy('start_time', descending: false)
          .get();

      _events = eventsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['event_id'] = doc.id;
        return EventModel.fromMap(data);
      }).toList();

      print('✅ Loaded ${_events.length} ongoing events');

    } catch (e) {
      _error = 'Failed to load ongoing events: $e';
      print('❌ Error loading ongoing events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          });

      // Update local state
      final index = _events.indexWhere((event) => event.eventId == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(status: status);
      }
      
      print('✅ Updated event status: $eventId -> $status');

    } catch (e) {
      _error = 'Failed to update event status: $e';
      print('❌ Error updating event status: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get event by ID
  Future<EventModel> getEventById(String eventId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .get();

      if (!doc.exists) {
        throw Exception('Event not found: $eventId');
      }

      final data = doc.data()!;
      data['event_id'] = doc.id;
      
      return EventModel.fromMap(data);
    } catch (e) {
      print('❌ Error getting event by ID: $e');
      throw Exception('Failed to get event: $e');
    }
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .delete();

      // Remove from local list
      _events.removeWhere((event) => event.eventId == eventId);
      
      print('✅ Deleted event: $eventId');
      
    } catch (e) {
      _error = 'Failed to delete event: $e';
      print('❌ Error deleting event: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search events by title
  Future<void> searchEvents(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (query.isEmpty) {
        await loadEvents();
        return;
      }

      final eventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      _events = eventsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['event_id'] = doc.id;
        return EventModel.fromMap(data);
      }).toList();

      print('✅ Searched events: found ${_events.length} results for "$query"');

    } catch (e) {
      _error = 'Failed to search events: $e';
      print('❌ Error searching events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Join an event
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the current event
      final event = await getEventById(eventId);
      
      // Check if event is full
      if (event.isFull) {
        throw Exception('Event is already full');
      }

      // Check if user is already participating
      if (event.participants.contains(userId)) {
        throw Exception('You are already participating in this event');
      }

      // Update participants list
      final updatedParticipants = List<String>.from(event.participants)..add(userId);
      
      await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .update({
            'participants': updatedParticipants,
            'current_participants': updatedParticipants.length,
            'updated_at': DateTime.now().toIso8601String(),
          });

      // Update local state
      final index = _events.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          participants: updatedParticipants,
          currentParticipants: updatedParticipants.length,
        );
      }
      
      print('✅ User $userId joined event: $eventId');

    } catch (e) {
      _error = 'Failed to join event: $e';
      print('❌ Error joining event: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Leave an event
  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the current event
      final event = await getEventById(eventId);
      
      // Check if user is participating
      if (!event.participants.contains(userId)) {
        throw Exception('You are not participating in this event');
      }

      // Update participants list
      final updatedParticipants = List<String>.from(event.participants)..remove(userId);
      
      await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .update({
            'participants': updatedParticipants,
            'current_participants': updatedParticipants.length,
            'updated_at': DateTime.now().toIso8601String(),
          });

      // Update local state
      final index = _events.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          participants: updatedParticipants,
          currentParticipants: updatedParticipants.length,
        );
      }
      
      print('✅ User $userId left event: $eventId');

    } catch (e) {
      _error = 'Failed to leave event: $e';
      print('❌ Error leaving event: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user is already participating in an event
  Future<bool> isUserParticipating(String eventId, String userId) async {
    try {
      final event = await getEventById(eventId);
      return event.participants.contains(userId);
    } catch (e) {
      print('❌ Error checking participation: $e');
      throw Exception('Failed to check participation: $e');
    }
  }

  /// Get event participation statistics
  Future<Map<String, dynamic>> getEventParticipationStats(String eventId) async {
    try {
      final participationsSnapshot = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .where('event_id', isEqualTo: eventId)
          .get();

      final totalParticipants = participationsSnapshot.docs.length;
      final attendedParticipants = participationsSnapshot.docs
          .where((doc) => doc['status'] == 'attended')
          .length;
      final totalHours = participationsSnapshot.docs.fold<int>(0, (sum, doc) {
        final data = doc.data();
        final hours = data['hours_contributed'] as int? ?? 0;
        return sum + hours;
      });

      final stats = {
        'total_participants': totalParticipants,
        'attended_participants': attendedParticipants,
        'attendance_rate': totalParticipants > 0 ? (attendedParticipants / totalParticipants * 100) : 0,
        'total_hours': totalHours,
      };

      print('✅ Event participation stats: $stats');
      return stats;

    } catch (e) {
      print('❌ Error getting participation stats: $e');
      throw Exception('Failed to get participation stats: $e');
    }
  }

  /// Get events by status
  List<EventModel> getEventsByStatus(String status) {
    return _events.where((event) => event.status == status).toList();
  }

  /// Get events that user is participating in
  List<EventModel> getEventsByParticipation(String userId) {
    return _events.where((event) => event.participants.contains(userId)).toList();
  }

  /// Get events with available spots
  List<EventModel> getEventsWithAvailableSpots() {
    return _events.where((event) => !event.isFull && event.isUpcoming).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await loadEvents();
  }

  /// Reset provider state
  void reset() {
    _events.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}