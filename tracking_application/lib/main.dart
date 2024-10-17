import 'package:flutter/material.dart';
import 'package:driver_tracking_package/driver_tracking_package.dart';

void main() => runApp(DriverApp());

class DriverApp extends StatefulWidget {
  @override
  DriverAppState createState() => DriverAppState();
}

class DriverAppState extends State<DriverApp> {
  String driverId = '';
  bool tracking = false;
  String statusMessage = 'Not Tracking';
  String latitude = '0.0';
  String longitude = '0.0';

  DriverTracker? _driverTracker;

  @override
  void dispose() {
    _driverTracker?.dispose();
    super.dispose();
  }

  void _startTracking() {
    if (driverId.isEmpty) {
      setState(() {
        statusMessage = 'Driver ID is required';
      });
      return;
    }

    _driverTracker = DriverTracker(driverId: driverId);

    // Listen to status updates
    _driverTracker!.statusStream.listen((status) {
      setState(() {
        statusMessage = status;
      });
    });

    // Listen to location updates
    _driverTracker!.locationStream.listen((location) {
      setState(() {
        latitude = location.latitude.toString();
        longitude = location.longitude.toString();
      });
    });

    _driverTracker!.startTracking();
    setState(() {
      tracking = true;
    });
  }

  void _stopTracking() {
    _driverTracker?.stopTracking();
    setState(() {
      tracking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Driver Tracking App')),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Enter Driver ID'),
                  onChanged: (value) => setState(() => driverId = value),
                  enabled: !tracking,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: tracking ? _stopTracking : _startTracking,
                  child: Text(tracking ? 'Stop Tracking' : 'Start Tracking'),
                ),
                SizedBox(height: 16.0),
                Text('Status: $statusMessage'),
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
