import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey;
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  WeatherService({required this.apiKey});

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    // If API key is not provided, return mock data for demonstration
    if (apiKey.isEmpty || apiKey == 'YOUR_WEATHER_API_KEY') {
      return {
        'temp': 22.0,
        'description': 'Sunny',
        'icon': '01d',
      };
    }

    final url = Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temp': data['main']['temp'],
          'description': data['weather'][0]['main'],
          'icon': data['weather'][0]['icon'],
        };
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      return {
        'temp': 22.0,
        'description': 'Sunny',
        'icon': '01d',
      };
    }
  }
}
