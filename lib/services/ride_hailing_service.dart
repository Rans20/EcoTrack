import 'package:url_launcher/url_launcher.dart';

class RideHailingService {
  Future<void> openUber(double lat, double lon, String address) async {
    // Attempt to open Uber with Eco-friendly options if possible via deep link params
    // 'product_id' could be used if we had specific city-based IDs for Uber Green
    final url = Uri.parse(
      'uber://?action=setPickup&dropoff[latitude]=$lat&dropoff[longitude]=$lon&dropoff[nickname]=$address',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse(
        'https://m.uber.com/ul/?action=setPickup&dropoff[latitude]=$lat&dropoff[longitude]=$lon',
      );
      await launchUrl(webUrl);
    }
  }

  Future<void> openLyft(double lat, double lon) async {
    // Lyft Pink/Green or standard Lyft with Eco focus
    final url = Uri.parse(
      'lyft://ridetype?id=lyft_eco&destination[latitude]=$lat&destination[longitude]=$lon',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse(
        'https://www.lyft.com/ride?id=lyft_eco&destination[latitude]=$lat&destination[longitude]=$lon',
      );
      await launchUrl(webUrl);
    }
  }

  double calculateCo2Saved(double distanceKm) {
    // Average ICE car emits ~0.17kg/km
    // Uber Green / EV emits ~0.05kg/km (accounting for energy grid)
    const averageEmission = 0.17;
    const ecoEmission = 0.05;
    return (averageEmission - ecoEmission) * distanceKm;
  }
}
