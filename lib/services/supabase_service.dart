import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import '../models/user_profile.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    /// TODO: REPLACE THESE PLACEHOLDERS
    /// 1. Go to Google Cloud Console -> APIs & Services -> Credentials.
    /// 2. Create an OAuth 2.0 Client ID for 'Web application'. Copy the 'Client ID' and paste it as [webClientId].
    /// 3. Create an OAuth 2.0 Client ID for 'iOS'. Copy the 'Client ID' and paste it as [iosClientId].
    /// 4. In Supabase Dashboard -> Auth -> Providers -> Google, enable it and paste the [webClientId].
    const webClientId = '.878635206146-adailjatpcffen700grddbgi5s0iponl.apps.googleusercontent.com';
    const iosClientId = '878635206146-nujep5778aj1j6uvo1f8eddn7f92lmm7.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'No Google Access Token/ID Token found.';
      }

      final AuthResponse res = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Create profile if it doesn't exist
      if (res.user != null) {
        final profile = await getCurrentUserProfile();
        if (profile == null) {
          final newProfile = UserProfile(
            id: res.user!.id,
            fullName: googleUser.displayName ?? '',
            heightCm: '',
            weightKg: '',
            nationality: '',
            country: '',
            city: '',
            car: 'Other',
            photoUrl: googleUser.photoUrl,
            createdAt: DateTime.now(),
          );
          await client.from('profiles').upsert(newProfile.toJson());
        }
      }
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, UserProfile profile, File? imageFile) async {
    try {
      final AuthResponse res = await client.auth.signUp(
        email: email, 
        password: password,
      );
      
      final user = res.user;
      if (user == null) throw 'Signup failed: No user returned';

      // NOTE: If 'Confirm Email' is ON in Supabase, the user is not authenticated yet.
      // The profile creation below might fail if your RLS policies require authentication.
      // Recommendation: Create profiles via a Database Webhook on 'auth.users' insert.
      
      String? photoUrl;
      if (imageFile != null) {
        try {
          photoUrl = await uploadProfilePicture(user.id, imageFile);
        } catch (e) {
          debugPrint('Warning: Failed to upload profile picture: $e');
        }
      }

      final newProfile = UserProfile(
        id: user.id,
        fullName: profile.fullName,
        heightCm: profile.heightCm,
        weightKg: profile.weightKg,
        nationality: profile.nationality,
        country: profile.country,
        city: profile.city,
        car: profile.car,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      // We attempt to create the profile. If it fails due to RLS, it's likely 
      // because the user hasn't confirmed their email yet.
      try {
        await client.from('profiles').upsert(newProfile.toJson());
      } catch (e) {
        debugPrint('Profile creation failed (possibly due to RLS/unconfirmed email): $e');
        // If email confirmation is required, this is expected to fail if RLS is strict.
      }
    } catch (e) {
      debugPrint('Error in signUp: $e');
      rethrow;
    }
  }

  Future<String?> uploadProfilePicture(String userId, File file) async {
    final extension = p.extension(file.path);
    final fileName = '$userId$extension';
    final filePath = 'avatars/$fileName';

    await client.storage.from('profiles').upload(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return client.storage.from('profiles').getPublicUrl(filePath);
  }

  Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        throw 'Please confirm your email address before signing in.';
      }
      rethrow;
    } catch (e) {
      debugPrint('Error in signIn: $e');
      rethrow;
    }
  }

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
