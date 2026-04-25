import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; // Deep Green
    final accentColor = theme.colorScheme.secondary; // Emerald
    final tertiaryColor = theme.colorScheme.tertiary; // Teal

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(primaryColor, tertiaryColor),
              const SizedBox(height: 32),
              _buildStatsRow(primaryColor, accentColor, tertiaryColor),
              const SizedBox(height: 24),
              _buildChartCard('Emission Trends', primaryColor, _buildLineChart(tertiaryColor)),
              const SizedBox(height: 24),
              _buildChartCard('Impact by Activity', primaryColor, _buildBarChart(accentColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, Color tertiaryColor) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryColor)),
            Text('Environmental footprint', style: TextStyle(fontSize: 14, color: tertiaryColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(Color primaryColor, Color accentColor, Color tertiaryColor) {
    return Row(
      children: [
        Expanded(child: _buildStatBox('Avg kg/day', '2.4', Icons.trending_up_rounded, tertiaryColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatBox('Total kg (6mo)', '432.1', Icons.eco_rounded, accentColor)),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECEFF1).withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade900)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Color primaryColor, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECEFF1).withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryColor)),
          const SizedBox(height: 28),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart(Color color) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3),
              const FlSpot(1, 1),
              const FlSpot(2, 4),
              const FlSpot(3, 2),
              const FlSpot(4, 5),
            ],
            isCurved: true,
            color: color,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color color) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: color, width: 16)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: color, width: 16)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: color, width: 16)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: color, width: 16)]),
        ],
      ),
    );
  }
}
