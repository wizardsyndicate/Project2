import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart'; // Import the permission handler package

class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data'); //this is the exception.
    }
  }

  Future<String> getCurrentCity() async {
    // Request location permission
    var status = await Permission.location.status;

    if (status.isDenied) {
      // Request permission if not granted
      status = await Permission.location.request();
      if (status.isDenied) {
        // Handle the case when the user denies permission
        throw Exception('Location permission denied');
      }
    }

    final LocationSettings locationSettings = LocationSettings( //pretty much all of this was from the pub.dev files.
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    // Get the placemarks based on the coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;

    return city ?? "";
  }
}
