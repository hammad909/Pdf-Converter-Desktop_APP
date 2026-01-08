import 'package:flutter/material.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherServices _weatherServices = WeatherServices();

  WeatherModel? _weather;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchWeather,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),

            _loading
                ? const CircularProgressIndicator()
                : _error != null
                    ? Text(_error!, style: const TextStyle(color: Colors.red))
                    : _weather == null
                        ? const Text('Enter a city and press Search')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('City: ${_weather!.cityName}', style: const TextStyle(fontSize: 20)),
                              Text('Temp: ${_weather!.temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 20)),
                              Text('Description: ${_weather!.description}', style: const TextStyle(fontSize: 20)),
                              Text('Humidity: ${_weather!.humidity}%', style: const TextStyle(fontSize: 20)),
                              Text('Wind Speed: ${_weather!.windSpeed} m/s', style: const TextStyle(fontSize: 20)),
                            ],
                          ),
          ],
        ),
      ),
    );
  }

  // 🔹 Function to search weather
  void _searchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _weather = null;
    });

    try {
      final weather = await _weatherServices.fetchWeather(city);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
