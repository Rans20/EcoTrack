import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import '../services/supabase_service.dart';
import '../services/weather_service.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double todayCo2 = 0.0;
  bool loading = true;
  Map<String, dynamic>? weatherData;
  String aiTip = 'Loading your personalized eco-tip...';
  String aiWeatherSuggestion = 'Fetching weather insights...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final supabase = context.read<SupabaseService>();
    final weatherService = context.read<WeatherService>();
    final aiService = context.read<AiService>();
    
    final co2 = await supabase.getTodayCo2Kg();
    
    // Get location for weather
    final location = Location();
    LocationData? locData;
    try {
      locData = await location.getLocation();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }

    if (locData != null) {
      weatherData = await weatherService.getWeather(locData.latitude!, locData.longitude!);
    } else {
      weatherData = {'temp': 22.0, 'description': 'Sunny', 'icon': '01d'};
    }

    aiTip = aiService.getSuggestion(weatherData!);
    aiWeatherSuggestion = aiService.getMorningNotification(weatherData!);

    if (mounted) {
      setState(() {
        todayCo2 = co2;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildDashboardCard(theme),
              const SizedBox(height: 32),
              _buildWeatherCard(theme),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Eco Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGrid(context, theme),
              const SizedBox(height: 32),
              _buildTipCard(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, EcoWarrior',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'Monday, October 14',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF95A5A6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final theme = Theme.of(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Sign Out', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            if (confirmed == true && context.mounted) {
              try {
                await context.read<SupabaseService>().signOut();
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            }
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.5), width: 2),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.person_outline, color: theme.colorScheme.primary, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(ThemeData theme) {
    final temp = weatherData?['temp'] ?? '--';
    final desc = weatherData?['description'] ?? 'Loading...';
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$desc • $temp°C',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Current Weather',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'AI ADVISOR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              aiWeatherSuggestion,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 35,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live CO₂ Impact',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.insights_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Live',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDashboardStat(todayCo2.toStringAsFixed(1), 'kg CO₂ today'),
              Container(width: 1.5, height: 50, color: Colors.white.withValues(alpha: 0.2)),
              _buildDashboardStat('142', 'Eco Points'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildGridCard(theme, Icons.map_outlined, 'Eco Maps', 'Smart routes', const Color(0xFFDFF9FB), const Color(0xFF22A6B3)),
        _buildGridCard(theme, Icons.pie_chart_outline, 'Analytics', 'CO₂ Insights', const Color(0xFFF1F2F6), const Color(0xFF535C68)),
        _buildGridCard(theme, Icons.emoji_events_outlined, 'Impact Board', 'Top Savers', const Color(0xFFFEF9E7), const Color(0xFFF1C40F)),
        _buildGridCard(theme, Icons.auto_awesome_outlined, 'Milestones', 'Achievements', const Color(0xFFEBF5FB), const Color(0xFF3498DB)),
      ],
    );
  }

  Widget _buildGridCard(ThemeData theme, IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Tip of the Day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              Icon(Icons.lightbulb_rounded, size: 24, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            aiTip,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
