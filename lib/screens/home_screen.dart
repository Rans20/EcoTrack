import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double todayCo2 = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = context.read<SupabaseService>();
    final co2 = await service.getTodayCo2Kg();
    setState(() {
      todayCo2 = co2;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; // Deep Green
    final accentColor = theme.colorScheme.secondary; // Emerald Green
    final tertiaryColor = theme.colorScheme.tertiary; // Teal

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(primaryColor, tertiaryColor),
              const SizedBox(height: 24),
              _buildWeatherCard(primaryColor, tertiaryColor),
              const SizedBox(height: 24),
              _buildDashboardCard(primaryColor, accentColor, tertiaryColor),
              const SizedBox(height: 32),
              Text(
                'Eco Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 16),
              _buildGrid(context, primaryColor, accentColor, tertiaryColor),
              const SizedBox(height: 24),
              _buildTipCard(tertiaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, Color tertiaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, EcoWarrior', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: primaryColor)),
            const Text('Monday, October 14', style: TextStyle(fontSize: 14, color: Color(0xFF78909C), fontWeight: FontWeight.w600)),
          ],
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: tertiaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: tertiaryColor.withValues(alpha: 0.2), width: 2),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.person, color: tertiaryColor),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(Color primaryColor, Color tertiaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECEFF1).withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 24),
              const SizedBox(width: 12),
              Text('Sunny • 22°C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('AI ADVISOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: tertiaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "It's a sunny day! Great time to bike or walk and soak up some Vitamin D while saving CO₂.",
            style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade700, fontWeight: FontWeight.w500, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(Color primaryColor, Color accentColor, Color tertiaryColor) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withBlue(40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 12))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live CO₂ Impact', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: accentColor),
                    const SizedBox(width: 6),
                    const Text('Tracking', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDashboardStat(todayCo2.toStringAsFixed(1), 'kg CO₂ today'),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildDashboardStat('142', 'Points earned'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, Color primaryColor, Color accentColor, Color tertiaryColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildGridCard(Icons.map, 'Eco Maps', 'Smart routes', tertiaryColor.withValues(alpha: 0.08), tertiaryColor),
        _buildGridCard(Icons.pie_chart, 'Analytics', 'CO2 Insights', accentColor.withValues(alpha: 0.08), accentColor),
        _buildGridCard(Icons.emoji_events, 'Global Board', 'Top Savers', Colors.amber.withValues(alpha: 0.08), Colors.amber.shade800),
        _buildGridCard(Icons.trending_up, 'Milestones', 'Achievements', Colors.blue.withValues(alpha: 0.08), Colors.blue.shade700),
      ],
    );
  }

  Widget _buildGridCard(IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECEFF1).withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade900)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTipCard(Color tertiaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tertiaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tertiaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AI Tip of the Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tertiaryColor.withValues(alpha: 0.8))),
              Icon(Icons.lightbulb_outline, size: 20, color: tertiaryColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Replace one car trip per week with biking or walking to reduce your footprint significantly.',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ],
      ),
    );
  }
}
