import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

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
              _buildStatsRow(theme),
              const SizedBox(height: 32),
              _buildChartCard(theme, 'Emission Trends', _buildLineChart(secondaryColor)),
              const SizedBox(height: 32),
              _buildChartCard(theme, 'Impact by Activity', _buildBarChart(primaryColor)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'Environmental footprint',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF95A5A6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildStatBox(theme, 'Avg kg/day', '2.4', Icons.trending_up_rounded, theme.colorScheme.secondary)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatBox(theme, 'Total kg (6mo)', '432.1', Icons.eco_rounded, theme.colorScheme.primary)),
      ],
    );
  }

  Widget _buildStatBox(ThemeData theme, String label, String value, IconData icon, Color color) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: -1),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(ThemeData theme, String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 32),
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
