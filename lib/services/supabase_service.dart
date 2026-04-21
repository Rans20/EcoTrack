import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final data = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> upsertUserProfile(UserProfile profile) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final data = await client
        .from('profiles')
        .upsert(profile.toJson())
        .select()
        .single();

    return UserProfile.fromJson(data);
  }

  Future<double> getTodayCo2Kg() async {
    final user = client.auth.currentUser;
    if (user == null) return 0.0;

    final now = DateTime.now();
    final since = DateTime(now.year, now.month, now.day).toIso8601String();

    final List<dynamic> data = await client
        .from('activities')
        .select('co2_kg')
        .eq('user_id', user.id)
        .gte('started_at', since);

    double total = 0.0;
    for (var row in data) {
      total += (row['co2_kg'] ?? 0.0).toDouble();
    }
    return total;
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard({int limit = 20}) async {
    final List<dynamic> data = await client
        .from('leaderboard')
        .select()
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchRouteSuggestions() async {
    final List<dynamic> data = await client
        .from('route_suggestions')
        .select()
        .order('sort_order');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
