import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = context.read<SupabaseService>().fetchLeaderboard();
  }

  String _formatLocation(Map<String, dynamic> item) {
    final city = item['city'] as String?;
    final country = item['country'] as String?;
    final parts = [if (city != null && city.isNotEmpty) city, if (country != null && country.isNotEmpty) country];
    return parts.isEmpty ? 'Unknown' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              // Stats Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(theme, Icons.people_outline, '1.2k', 'Active'),
                  _buildMiniStat(theme, Icons.workspace_premium_outlined, '#42', 'Your Rank'),
                  _buildMiniStat(theme, Icons.badge_outlined, '8', 'Badges'),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Global Rankings',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'This Week',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _leaderboardFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                            }
                            final entries = snapshot.data ?? [];
                            if (entries.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No activity yet.\nLog a journey to appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF95A5A6), fontWeight: FontWeight.w500),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: entries.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = entries[index];
                                return _buildLeaderboardRow(theme, index, item);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
          child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact Leaders',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'Top eco-warriors globally',
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

  Widget _buildMiniStat(ThemeData theme, IconData icon, String value, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.26,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.secondary, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: -0.5),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF95A5A6), fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(ThemeData theme, int index, Map<String, dynamic> item) {
    Color rankColor = const Color(0xFFF1F2F6);
    Color rankTextColor = const Color(0xFF535C68);
    if (index == 0) {
      rankColor = const Color(0xFFFFEAA7);
      rankTextColor = const Color(0xFFD35400);
    } else if (index == 1) {
      rankColor = const Color(0xFFDFE6E9);
      rankTextColor = const Color(0xFF2D3436);
    } else if (index == 2) {
      rankColor = const Color(0xFFFAB1A0).withValues(alpha: 0.3);
      rankTextColor = const Color(0xFFE17055);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(fontWeight: FontWeight.w900, color: rankTextColor, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['full_name'] ?? 'Anonymous',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                ),
                Text(
                  '${_formatLocation(item)} — ${item['activity_mode'] ?? 'personal'}',
                  style: const TextStyle(color: Color(0xFF95A5A6), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(item['total_co2_kg'] ?? 0.0).toStringAsFixed(1)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: -0.5),
              ),
              const Text(
                'KG CO₂',
                style: TextStyle(fontSize: 9, color: Color(0xFFB2BEC3), fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
