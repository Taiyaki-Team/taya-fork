import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:omi/backend/preferences.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? address;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? placeName;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.address,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.placeName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'address': address,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'place_name': placeName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      accuracy: json['accuracy'] ?? 0.0,
      address: json['address'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      placeName: json['place_name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String getDisplayAddress() {
    if (address != null && address!.isNotEmpty) return address!;
    
    List<String> parts = [];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    
    if (parts.isEmpty) {
      return 'Location: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
    
    return parts.join(', ');
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location tracking is enabled in settings
  bool isLocationTrackingEnabled() {
    return SharedPreferencesUtil().locationTrackingEnabled ?? true;
  }

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Get current location with address
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location tracking is enabled
      if (!isLocationTrackingEnabled()) {
        debugPrint('Location tracking is disabled in settings');
        return null;
      }

      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('Got location: ${position.latitude}, ${position.longitude}');

      // Reverse geocode to get address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          
          // Build full address
          List<String> addressParts = [];
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
            addressParts.add(place.subThoroughfare!);
          }
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            addressParts.add(place.thoroughfare!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          }

          return LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            address: addressParts.isNotEmpty ? addressParts.join(', ') : null,
            street: place.thoroughfare,
            city: place.locality,
            state: place.administrativeArea,
            country: place.country,
            postalCode: place.postalCode,
            placeName: place.name,
            timestamp: DateTime.now(),
          );
        }
      } catch (e) {
        debugPrint('Error reverse geocoding: $e');
        // Return location without address if geocoding fails
      }

      // Return location without address details
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Get location in the background (with lower accuracy for battery saving)
  Future<LocationData?> getBackgroundLocation() async {
    try {
      if (!isLocationTrackingEnabled()) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting background location: $e');
      return null;
    }
  }
}

