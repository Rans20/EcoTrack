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
        Container(
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
      ],
    );
  }

  Widget _buildWeatherCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFBE76), size: 28),
              const SizedBox(width: 12),
              Text(
                'Sunny • 22°C',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI ADVISOR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "It's a sunny day! Great time to bike or walk and soak up some Vitamin D while saving CO₂.",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF636E72),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
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
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Tracking',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDashboardStat(todayCo2.toStringAsFixed(1), 'kg CO₂ today'),
              Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.2)),
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
          const Text(
            'Replace one car trip per week with biking or walking to reduce your footprint significantly.',
            style: TextStyle(
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
