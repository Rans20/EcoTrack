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
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Impact Leaders', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A237E))),
                      Text('Top eco-warriors globally', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF00BFA5), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(Icons.people, '1.2k', 'Active'),
                  _buildMiniStat(Icons.workspace_premium, '#42', 'Your Rank'),
                  _buildMiniStat(Icons.badge, '8', 'Badges'),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFF0F7F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4332).withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Global Rankings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('This Week', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF00BFA5))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _leaderboardFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            final entries = snapshot.data ?? [];
                            if (entries.isEmpty) {
                              return const Center(child: Text('No activity yet. Log a journey to appear here.', style: TextStyle(color: Color(0xFF95D5B2))));
                            }
                            return ListView.separated(
                              itemCount: entries.length,
                              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF0F7F0)),
                              itemBuilder: (context, index) {
                                final item = entries[index];
                                return _buildLeaderboardRow(index, item);
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

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F7F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2D6A4F), size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF00BFA5), fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(int index, Map<String, dynamic> item) {
    Color rankColor = const Color(0xFFF0F7F0);
    Color rankTextColor = const Color(0xFF409167);
    if (index == 0) { rankColor = const Color(0xFFFFD700); rankTextColor = Colors.white; }
    else if (index == 1) { rankColor = const Color(0xFFC0C0C0); rankTextColor = Colors.white; }
    else if (index == 2) { rankColor = const Color(0xFFCD7F32); rankTextColor = Colors.white; }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w800, color: rankTextColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['full_name'] ?? 'Anonymous', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                Text('${_formatLocation(item)} — ${item['activity_mode'] ?? 'personal'}', style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(item['total_co2_kg'] ?? 0.0).toStringAsFixed(1)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF00BFA5))),
              const Text('KG', style: TextStyle(fontSize: 10, color: Color(0xFF546E7A), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
