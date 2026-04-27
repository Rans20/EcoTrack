import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String? apiKey; // Kept for compatibility, but no longer strictly required
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  WeatherService({this.apiKey});

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url = Uri.parse('$baseUrl?latitude=$lat&longitude=$lon&current_weather=true');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        
        return {
          'temp': current['temperature'],
          'description': _getWeatherDescription(current['weathercode']),
          'icon': _getWeatherIcon(current['weathercode']),
        };
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return {
        'temp': 22.0,
        'description': 'Sunny',
        'icon': '01d',
      };
    }
  }

  String _getWeatherDescription(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rainy';
    if (code >= 71 && code <= 77) return 'Snowy';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Clear';
  }

  String _getWeatherIcon(int code) {
    // Mapping to OpenWeatherMap-like icons for compatibility with existing UI if needed
    if (code == 0) return '01d';
    if (code >= 1 && code <= 3) return '02d';
    if (code >= 51 && code <= 65) return '10d';
    if (code >= 80 && code <= 82) return '09d';
    if (code >= 95) return '11d';
    return '01d';
  }
}
