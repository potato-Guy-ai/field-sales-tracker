import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../repositories/route_repository.dart';
import '../services/location_service.dart';
import '../models/route.dart';

class RouteTracker {
  final RouteRepository _routeRepo = RouteRepository();
  final LocationService _locationService = LocationService.instance;
  
  String? _currentRouteId;
  StreamSubscription<Position>? _trackingSubscription;
  
  bool get isTracking => _trackingSubscription != null;
  String? get currentRouteId => _currentRouteId;

  Future<bool> startTracking() async {
    if (isTracking) return true;
    
    final hasPermission = await _locationService.checkPermissions();
    if (!hasPermission) return false;

    // Check if there's already an active route
    Route? activeRoute = await _routeRepo.getActiveRoute();
    
    // If no active route, check if we're near any existing route
    if (activeRoute == null) {
      final currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition != null) {
        final nearbyRoute = await _routeRepo.findNearbyRoute(
          currentPosition.latitude,
          currentPosition.longitude,
        );
        
        if (nearbyRoute != null) {
          // Reuse existing route
          _currentRouteId = nearbyRoute.id;
        } else {
          // Create new route
          _currentRouteId = await _routeRepo.createRoute();
        }
      } else {
        // Create new route anyway
        _currentRouteId = await _routeRepo.createRoute();
      }
    } else {
      _currentRouteId = activeRoute.id;
    }

    // Start location tracking
    _trackingSubscription = _locationService.startTracking().listen((position) {
      if (_currentRouteId != null) {
        _routeRepo.addRoutePoint(_currentRouteId!, position);
      }
    });

    return true;
  }

  Future<void> stopTracking() async {
    if (_currentRouteId != null) {
      await _routeRepo.deactivateRoute(_currentRouteId!);
    }
    
    _trackingSubscription?.cancel();
    _trackingSubscription = null;
    _locationService.stopTracking();
    _currentRouteId = null;
  }

  Future<List<RoutePoint>> getCurrentRoutePoints() async {
    if (_currentRouteId == null) return [];
    return await _routeRepo.getRoutePoints(_currentRouteId!);
  }

  Future<Position?> getCurrentPosition() async {
    return await _locationService.getCurrentLocation();
  }
}
