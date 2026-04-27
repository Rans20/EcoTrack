class AiService {
  String getSuggestion(Map<String, dynamic> weatherData) {
    final temp = weatherData['temp'] as double;
    final description = weatherData['description'] as String;

    if (description.contains('Rain') || description.contains('Thunderstorm') || description.contains('Showers')) {
      return 'Rainy weather today. Emissions-friendly tip: Use public transit or carpool to reduce the high carbon impact of individual car trips in heavy traffic.';
    } else if (temp > 18 && (description == 'Clear' || description == 'Partly Cloudy')) {
      return 'It’s a beautiful day! Choosing to walk or bike instead of driving can reduce your daily CO2 footprint by up to 2-3kg.';
    } else if (temp < 8) {
      return 'Cold weather alert. If you must drive, optimize your car’s warmth and tire pressure to save up to 10% on fuel and emissions.';
    } else if (description == 'Foggy') {
      return 'Foggy morning. Consider working from home if possible to avoid high-emission traffic idling in poor visibility.';
    } else {
      return 'Moderate weather today. A 15-minute walk for short errands saves CO2 and helps you stay active!';
    }
  }

  String getMorningNotification(Map<String, dynamic> weatherData) {
    final suggestion = getSuggestion(weatherData);
    return 'Good morning! $suggestion';
  }
}
