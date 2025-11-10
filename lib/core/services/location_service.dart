import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class LocationService {
  // Initialize location service
  Future<void> init() async {
    // You can add any initialization logic here if needed
    await _requestPermission();
  }

  Future<bool> _requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please grant location permissions in app settings.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable location permissions in device settings.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Get last known position (cached location)
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  // Get distance between two points in meters
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculate distance between two positions
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Check if location is within radius (in meters)
  bool isWithinRadius(
    double userLat,
    double userLng,
    double targetLat,
    double targetLng,
    double radiusMeters,
  ) {
    final distance = getDistanceBetween(userLat, userLng, targetLat, targetLng);
    return distance <= radiusMeters;
  }

  // Get bearing between two points
  double getBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Stream location updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream();
  }

  // Check if we have required permissions
  Future<bool> hasLocationPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Check if permissions are permanently denied
  Future<bool> isPermissionPermanentlyDenied() async {
    final permission = await checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  // Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Open app settings for permission management
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Get formatted address from position (basic version)
  Future<String> getFormattedAddress(Position position) async {
    try {
      // In a real app, you would use Google Maps Geocoding API or similar
      // For now, return coordinates as string
      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'Unknown location';
    }
  }

  // Get readable distance string
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Calculate approximate walking time in minutes
  int calculateWalkingTime(double distanceInMeters) {
    // Average walking speed: 5 km/h = 83.33 m/min
    const double walkingSpeedMetersPerMinute = 83.33;
    final minutes = (distanceInMeters / walkingSpeedMetersPerMinute).ceil();
    return minutes.clamp(1, 180); // Cap at 3 hours
  }

  // Validate coordinates
  bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  // Get boundary coordinates for a radius (for map bounds)
  Map<String, double> getBoundsForRadius(
    double centerLat,
    double centerLng,
    double radiusMeters,
  ) {
    // Approximate conversion: 1 degree latitude ≈ 111 km
    // 1 degree longitude ≈ 111 km * cos(latitude)
    const double metersPerDegreeLat = 111000;
    final double metersPerDegreeLng = 111000 * math.cos(centerLat * math.pi / 180);

    final double latDelta = radiusMeters / metersPerDegreeLat;
    final double lngDelta = radiusMeters / metersPerDegreeLng;

    return {
      'minLat': centerLat - latDelta,
      'maxLat': centerLat + latDelta,
      'minLng': centerLng - lngDelta,
      'maxLng': centerLng + lngDelta,
    };
  }

  // Calculate center point of multiple coordinates
  Map<String, double> calculateCenter(List<Map<String, double>> coordinates) {
    if (coordinates.isEmpty) {
      throw Exception('No coordinates provided');
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final coord in coordinates) {
      totalLat += coord['latitude'] ?? 0;
      totalLng += coord['longitude'] ?? 0;
    }

    return {
      'latitude': totalLat / coordinates.length,
      'longitude': totalLng / coordinates.length,
    };
  }

  // Check if location is valid for Urban Green Mapper (within reasonable bounds)
  bool isValidForApp(Position position) {
    // Example: Check if within a specific country/city bounds
    // For now, just validate coordinates
    return isValidCoordinates(position.latitude, position.longitude);
  }

  // Get location accuracy level as string
  String getAccuracyLevel(double accuracy) {
    if (accuracy < 10) return 'High';
    if (accuracy < 50) return 'Good';
    if (accuracy < 100) return 'Moderate';
    return 'Low';
  }

  // Request location permissions with detailed explanation
  Future<LocationPermission> requestPermissionWithExplanation() async {
    // Check current permission status
    LocationPermission permission = await checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await requestPermission();
    }
    
    return permission;
  }

  // Get location with fallback to last known position
  Future<Position> getLocationWithFallback() async {
    try {
      return await getCurrentPosition();
    } catch (e) {
      // Try to get last known position
      final lastKnown = await getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      rethrow;
    }
  }

  // Check if location is near a green space (within 500 meters)
  bool isNearGreenSpace(Position userPosition, Map<String, double> greenSpaceLocation) {
    final distance = getDistanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      greenSpaceLocation['latitude'] ?? 0,
      greenSpaceLocation['longitude'] ?? 0,
    );
    return distance <= 500; // Within 500 meters
  }

  // Get all green spaces within radius
  List<Map<String, dynamic>> filterGreenSpacesByDistance(
    Position userPosition,
    List<Map<String, dynamic>> greenSpaces,
    double radiusMeters,
  ) {
    return greenSpaces.where((space) {
      final spaceLocation = space['location'] as Map<String, double>?;
      if (spaceLocation == null) return false;
      
      final distance = getDistanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        spaceLocation['latitude'] ?? 0,
        spaceLocation['longitude'] ?? 0,
      );
      
      return distance <= radiusMeters;
    }).toList();
  }

  // Sort green spaces by distance
  List<Map<String, dynamic>> sortGreenSpacesByDistance(
    Position userPosition,
    List<Map<String, dynamic>> greenSpaces,
  ) {
    greenSpaces.sort((a, b) {
      final locationA = a['location'] as Map<String, double>?;
      final locationB = b['location'] as Map<String, double>?;
      
      final distanceA = locationA != null 
          ? getDistanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              locationA['latitude'] ?? 0,
              locationA['longitude'] ?? 0,
            )
          : double.maxFinite;
          
      final distanceB = locationB != null
          ? getDistanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              locationB['latitude'] ?? 0,
              locationB['longitude'] ?? 0,
            )
          : double.maxFinite;
          
      return distanceA.compareTo(distanceB);
    });
    
    return greenSpaces;
  }

  // Get nearest green space
  Map<String, dynamic>? getNearestGreenSpace(
    Position userPosition,
    List<Map<String, dynamic>> greenSpaces,
  ) {
    if (greenSpaces.isEmpty) return null;

    final sorted = sortGreenSpacesByDistance(userPosition, greenSpaces);
    return sorted.first;
  }

  // Calculate total distance for a route (multiple points)
  double calculateRouteDistance(List<Map<String, double>> routePoints) {
    if (routePoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      final pointA = routePoints[i];
      final pointB = routePoints[i + 1];
      
      totalDistance += getDistanceBetween(
        pointA['latitude'] ?? 0,
        pointA['longitude'] ?? 0,
        pointB['latitude'] ?? 0,
        pointB['longitude'] ?? 0,
      );
    }

    return totalDistance;
  }

  // Check if user is moving (based on position changes)
  bool isUserMoving(Position previous, Position current, {double thresholdMeters = 10.0}) {
    final distance = calculateDistance(previous, current);
    return distance > thresholdMeters;
  }

  // Get approximate area in square meters for a polygon
  double calculatePolygonArea(List<Map<String, double>> polygon) {
    if (polygon.length < 3) return 0.0;

    double area = 0.0;
    final int n = polygon.length;

    for (int i = 0; i < n; i++) {
      final current = polygon[i];
      final next = polygon[(i + 1) % n];
      
      area += (current['longitude']! * next['latitude']!) - 
              (next['longitude']! * current['latitude']!);
    }

    return (area.abs() / 2.0) * 111000 * 111000; // Convert to square meters
  }

  // Get location status summary
  Future<Map<String, dynamic>> getLocationStatus() async {
    final serviceEnabled = await isLocationServiceEnabled();
    final permission = await checkPermission();
    final hasPermission = await hasLocationPermission();
    final lastKnownPosition = await getLastKnownPosition();

    return {
      'serviceEnabled': serviceEnabled,
      'permission': permission.toString(),
      'hasPermission': hasPermission,
      'lastKnownPosition': lastKnownPosition?.toMap(),
      'isPermissionPermanentlyDenied': permission == LocationPermission.deniedForever,
    };
  }

  // Get current location with retry mechanism
  Future<Position> getCurrentPositionWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await getCurrentPosition();
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    throw Exception('Failed to get location after $maxRetries attempts');
  }
}

// Extension for Position class
extension PositionExtensions on Position {
  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
    };
  }

  // Check if position is recent (within last 5 minutes)
  bool get isRecent {
    return timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 5)));
  }

  // Get formatted coordinates string
  String get formattedCoordinates {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Calculate distance to another position
  double distanceTo(Position other) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  // Calculate distance to coordinates
  double distanceToCoordinates(double targetLat, double targetLng) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      targetLat,
      targetLng,
    );
  }

  // Check if this position is approximately equal to another
  bool isApproximatelyEqual(Position other, {double toleranceMeters = 10.0}) {
    return distanceTo(other) <= toleranceMeters;
  }
}