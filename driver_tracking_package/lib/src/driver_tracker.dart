import 'dart:async';
import 'package:flutter/foundation.dart';
import 'location_service.dart';
import 'permission_service.dart';
import 'socket_manager.dart';
import 'models/driver_location.dart';

class DriverTracker {
  final String driverId;
  late final PermissionService _permissionService;
  late final LocationService _locationService;
  late final SocketManager _socketManager;

  bool _isTracking = false;
  StreamSubscription<DriverLocation>? _locationSubscription;

  // Streams to communicate with the application
  final _statusController = StreamController<String>.broadcast();
  final _locationController = StreamController<DriverLocation>.broadcast();

  Stream<String> get statusStream => _statusController.stream;
  Stream<DriverLocation> get locationStream => _locationController.stream;

  DriverTracker({required this.driverId}) {
    _permissionService = PermissionService();
    _locationService = LocationService();
    _socketManager = SocketManager(driverId: driverId);
  }

  Future<void> startTracking() async {
    if (_isTracking) {
      _statusController.add('Already tracking');
      return;
    }

    // Check and request permissions
    bool permissionGranted =
        await _permissionService.checkAndRequestPermissions();
    if (!permissionGranted) {
      _statusController.add('Location permissions not granted');
      return;
    }

    // Initialize socket
    await _socketManager.initSocket();

    // Start tracking
    _isTracking = true;
    _statusController.add('Tracking started');

    // Send initial location with "start" status
    await _sendLocation('start');

    // Start continuous location updates
    _locationSubscription =
        _locationService.getLocationStream().listen((location) {
      _locationController.add(location);
      _socketManager.sendLocation('update', location);
    });
  }

  Future<void> stopTracking() async {
    if (!_isTracking) {
      _statusController.add('Not tracking');
      return;
    }

    // Stop location updates
    await _locationSubscription?.cancel();

    // Send final location with "end" status
    await _sendLocation('end');

    // Close the socket connection
    await _socketManager.closeSocket();

    _isTracking = false;
    _statusController.add('Tracking stopped');
  }

  Future<void> _sendLocation(String status) async {
    try {
      DriverLocation location = await _locationService.getCurrentLocation();
      _locationController.add(location);
      _socketManager.sendLocation(status, location);
    } catch (e) {
      _statusController.add('Error getting location: $e');
    }
  }

  void dispose() {
    _locationSubscription?.cancel();
    _statusController.close();
    _locationController.close();
  }
}
