import 'package:flutter_test/flutter_test.dart';
import 'package:footprynt/services/ai_service.dart';

void main() {
  group('AiService Tests', () {
    final aiService = AiService();

    test('getSuggestion returns biking tip for sunny and warm weather', () {
      final weatherData = {'temp': 25.0, 'description': 'Clear'};
      final tip = aiService.getSuggestion(weatherData);
      expect(tip, contains('bike ride'));
    });

    test('getSuggestion returns carpool tip for rainy weather', () {
      final weatherData = {'temp': 15.0, 'description': 'Rain'};
      final tip = aiService.getSuggestion(weatherData);
      expect(tip, contains('carpooling'));
    });

    test('getSuggestion returns walking tip for pleasant weather', () {
      final weatherData = {'temp': 18.0, 'description': 'Cloudy'};
      final tip = aiService.getSuggestion(weatherData);
      expect(tip, contains('walk'));
    });

    test('getMorningNotification includes suggestion', () {
      final weatherData = {'temp': 25.0, 'description': 'Clear'};
      final notification = aiService.getMorningNotification(weatherData);
      expect(notification, contains('Good morning!'));
      expect(notification, contains('bike ride'));
    });
  });
}
