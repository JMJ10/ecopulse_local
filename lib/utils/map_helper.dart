// map_helper.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecopulse_local/models/recyclingcenter.dart';

class MapHelper {
  // Generate markers for recycling centers
  static Set<Marker> generateCenterMarkers(
    List<RecyclingCenter> centers, 
    Function(RecyclingCenter) onTap
  ) {
    return centers.map((center) => Marker(
      markerId: MarkerId(center.id),
      position: LatLng(
        center.location.latitude,
        center.location.longitude,
      ),
      infoWindow: InfoWindow(
        title: center.name,
        snippet: center.address,
      ),
      onTap: () => onTap(center),
    )).toSet();
  }
  
  // Generate user location marker
  static Marker generateUserMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId('user_location'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Your Location'),
      zIndex: 2, // Make user marker appear on top
    );
  }
  
  // Calculate bounds to fit all markers and user location
  static LatLngBounds calculateBounds(List<RecyclingCenter> centers, LatLng? userLocation) {
    if (centers.isEmpty && userLocation == null) {
      // Default bounds if we have no points
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(1, 1),
      );
    }
    
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;
    
    // Include user location in bounds if available
    if (userLocation != null) {
      minLat = userLocation.latitude;
      maxLat = userLocation.latitude;
      minLng = userLocation.longitude;
      maxLng = userLocation.longitude;
    }
    
    // Expand bounds to include all centers
    for (var center in centers) {
      minLat = (center.location.latitude < minLat) ? center.location.latitude : minLat;
      maxLat = (center.location.latitude > maxLat) ? center.location.latitude : maxLat;
      minLng = (center.location.longitude < minLng) ? center.location.longitude : minLng;
      maxLng = (center.location.longitude > maxLng) ? center.location.longitude : maxLng;
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}