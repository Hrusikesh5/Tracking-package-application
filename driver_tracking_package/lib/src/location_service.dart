import 'package:geolocator/geolocator.dart';
import 'models/driver_location.dart';

class LocationService {
  Future<DriverLocation> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return DriverLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Stream<DriverLocation> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).map((Position position) {
      return DriverLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }
}
