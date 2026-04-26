class AiService {
  String getSuggestion(Map<String, dynamic> weatherData) {
    final temp = weatherData['temp'] as double;
    final description = weatherData['description'] as String;

    if (description.contains('Rain') || description.contains('Thunderstorm')) {
      return 'It’s rainy today. Consider carpooling or using public transit to stay dry while reducing emissions compared to solo driving.';
    } else if (temp > 20 && description.contains('Clear')) {
      return 'Perfect weather for a bike ride! You can save roughly 0.4kg of CO2 per kilometer compared to driving.';
    } else if (temp < 10) {
      return 'It’s a bit chilly. If you must drive, ensure your tires are properly inflated to optimize fuel efficiency and reduce CO2.';
    } else {
      return 'Great day for a walk. Reach your step goal and save CO2 at the same time!';
    }
  }

  String getMorningNotification(Map<String, dynamic> weatherData) {
    final suggestion = getSuggestion(weatherData);
    return 'Good morning! $suggestion';
  }
}
