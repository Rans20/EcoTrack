import 'package:url_launcher/url_launcher.dart';

class RideHailingService {
  Future<void> openUber(double lat, double lon, String address) async {
    final url = Uri.parse(
      'uber://?action=setPickup&dropoff[latitude]=$lat&dropoff[longitude]=$lon&dropoff[nickname]=$address',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback to web
      final webUrl = Uri.parse(
        'https://m.uber.com/ul/?action=setPickup&dropoff[latitude]=$lat&dropoff[longitude]=$lon',
      );
      await launchUrl(webUrl);
    }
  }

  Future<void> openLyft(double lat, double lon) async {
    final url = Uri.parse(
      'lyft://ridetype?id=lyft_eco&destination[latitude]=$lat&destination[longitude]=$lon',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback to web
      final webUrl = Uri.parse(
        'https://www.lyft.com/ride?id=lyft_eco&destination[latitude]=$lat&destination[longitude]=$lon',
      );
      await launchUrl(webUrl);
    }
  }
}
