// location_service.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check and request location permission
  static Future<bool> checkLocationPermission(BuildContext context) async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog asking user to enable location services
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text('Please enable location services in your device settings to continue.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Show dialog with instructions to enable in settings
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Denied'),
              content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  // Get current user location
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    try {
      bool hasPermission = await checkLocationPermission(context);
      if (!hasPermission) return null;
      
      // Try with last known position for faster response
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      
      // Then get current position for accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<Position?> getMockLocationForEmulator() async {
  // Example: Kerala, India coordinates
  const double latitude = 10.8505;
  const double longitude = 76.2711;
  
  // Create a mock Position object
  return Position(
    latitude: latitude,
    longitude: longitude,
    accuracy: 10.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    timestamp: DateTime.now(),
    // Add these fields for newer versions of geolocator
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );
}
}