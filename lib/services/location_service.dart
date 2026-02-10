import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  StreamController<Position>? _positionStreamController;
  StreamSubscription<Position>? _positionSubscription;

  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    if (!await checkPermissions()) return null;
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> startTracking() {
    _positionStreamController = StreamController<Position>.broadcast();
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      _positionStreamController?.add(position);
    });

    return _positionStreamController!.stream;
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionStreamController?.close();
    _positionSubscription = null;
    _positionStreamController = null;
  }

  double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  bool isNearLocation(
    Position current,
    double targetLat,
    double targetLon, {
    double thresholdMeters = 50,
  }) {
    final distance = calculateDistance(
      current.latitude,
      current.longitude,
      targetLat,
      targetLon,
    );
    return distance <= thresholdMeters;
  }
}
