import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../core/database/database_helper.dart';
import '../models/route.dart';

class RouteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createRoute({String? name}) async {
    final db = await _dbHelper.database;
    final routeId = _uuid.v4();
    
    await db.insert('routes', {
      'id': routeId,
      'name': name,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_active': 1,
    });
    
    return routeId;
  }

  Future<void> addRoutePoint(String routeId, Position position) async {
    final db = await _dbHelper.database;
    await db.insert('route_points', {
      'id': _uuid.v4(),
      'route_id': routeId,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Route?> getActiveRoute() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'routes',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Route.fromMap(result.first);
  }

  Future<void> deactivateRoute(String routeId) async {
    final db = await _dbHelper.database;
    await db.update(
      'routes',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [routeId],
    );
  }

  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'route_points',
      where: 'route_id = ?',
      whereArgs: [routeId],
      orderBy: 'timestamp ASC',
    );
    return result.map((map) => RoutePoint.fromMap(map)).toList();
  }

  Future<Route?> findNearbyRoute(double latitude, double longitude) async {
    final db = await _dbHelper.database;
    
    // Get all routes
    final routes = await db.query('routes', where: 'is_active = ?', whereArgs: [0]);
    
    for (final routeMap in routes) {
      final route = Route.fromMap(routeMap);
      final points = await getRoutePoints(route.id);
      
      // Check if any point is within 100 meters
      for (final point in points) {
        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          point.latitude,
          point.longitude,
        );
        
        if (distance <= 100) {
          return route;
        }
      }
    }
    
    return null;
  }

  Future<List<Route>> getAllRoutes() async {
    final db = await _dbHelper.database;
    final result = await db.query('routes', orderBy: 'created_at DESC');
    return result.map((map) => Route.fromMap(map)).toList();
  }

  Future<void> deleteRoute(String routeId) async {
    final db = await _dbHelper.database;
    await db.delete('routes', where: 'id = ?', whereArgs: [routeId]);
  }
}
