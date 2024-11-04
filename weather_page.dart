import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:proj2/models/weather_model.dart';
import 'package:proj2/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherpageState();
}

class _WeatherpageState extends State<WeatherPage> {
  final _weatherService = WeatherService('e7b3857b8878aa2c62bf77216a957b5e');
  Weather? _weather;
  bool _isDarkMode = false; // State to track the current theme mode

  // Fetch the weather for a specific city
  _fetchWeather(String cityName) async {
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
      // Optionally handle errors here
    }
  }

  // Get the appropriate weather animation
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'animations/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'animations/clouds.json';
      case 'rain':
        return 'animations/rain.json';
      case 'thunderstorm':
        return 'animations/cloudyandthunder.json';
      case 'clear':
        return 'animations/sunny.json';
      default:
        return 'animations/sunny.json';
    }
  }

  @override
  Future<void> initState() async {
    super.initState();
    // Fetch weather for the current city on startup
    _fetchWeather(await _weatherService.getCurrentCity());
  }

  // Show dialog to enter city name
  void _showCityInputDialog() {
    final TextEditingController _cityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Want to Find a New City?'),
          content: TextField(
            controller: _cityController,
            decoration: InputDecoration(
              hintText: 'City name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String cityName = _cityController.text;
                if (cityName.isNotEmpty) {
                  _fetchWeather(cityName); 
                }
                Navigator.of(context).pop(); 
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rylee’s Weather App',
          style: TextStyle(
            color: _isDarkMode ? const Color.fromARGB(255, 233, 230, 230) : Colors.black, 
          ),
        ),
        centerTitle: true,
        backgroundColor: _isDarkMode ? Colors.grey[850] : const Color.fromARGB(255, 255, 255, 141),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: _isDarkMode ? Colors.white : Colors.black, 
            ),
            onPressed: () {
              
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: _isDarkMode ? Colors.white : Colors.black, 
            ),
            onPressed: () {
              _showCityInputDialog(); 
            },
          ),
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      backgroundColor: _isDarkMode ? Colors.black : Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weather?.cityName ?? "Loading city....", 
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            // Animations
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
            // Temperature
            Text(
              '${_weather?.temperature.round()}°C',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            // Weather condition
            Text(
              _weather?.mainCondition ?? "",
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
