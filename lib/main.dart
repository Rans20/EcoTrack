import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'models/user_profile.dart';
import 'services/supabase_service.dart';
import 'screens/home_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// SETUP INSTRUCTIONS FOR SUPABASE:
  /// 1. Go to Supabase Dashboard -> Project Settings -> API.
  /// 2. Copy 'Project URL' and 'anon key' (Public).
  /// 3. Go to Auth -> Providers:
  ///    - Email: Enable 'Confirm Email' if you want verification (requires additional handling for profile creation).
  ///    - Google: Enable and provide Client ID from Google Cloud Console.
  /// 4. For Google Sign-In on Android:
  ///    - Add SHA-1 fingerprint to Google Cloud Console and Firebase (if using google-services.json).
  ///    - Add the Web Client ID to Supabase Google Provider configuration.
  await Supabase.initialize(
    url: 'https://gzwciujlrsaoxunqjojl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd6d2NpdWpscnNhb3h1bnFqb2psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MTUxOTcsImV4cCI6MjA5MjE5MTE5N30.SRFiSebyzaK4J5nf0arK4Hg8xWvSZHzBdgGZV98jtwo ', // FIXME: Replace with your actual anon key
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(create: (_) => SupabaseService()),
      ],
      child: const FootpryntApp(),
    ),
  );
}

class FootpryntApp extends StatelessWidget {
  const FootpryntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Footprynt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E2A3A), // Dark Navy
          primary: const Color(0xFF1B5E20), // Deep Green
          secondary: const Color(0xFF00C853), // Emerald Green
          tertiary: const Color(0xFF26A69A), // Teal
          surface: const Color(0xFFF1F5F2), // Very Light Mint Gray
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF9FBF9),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return const MainNavigation();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo/logo.png', width: 220, height: 220),
              const SizedBox(height: 24),
              const Text(
                'Footprynt',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E2A3A),
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'TRACK • REDUCE • IMPACT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF546E7A),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<SupabaseService>().signInWithGoogle();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigation()),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing in: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2A3A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: const Color(0xFF1E2A3A).withValues(alpha: 0.4),
                ),
                child: const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(
                  'Sign In with Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                try {
                  await context.read<SupabaseService>().signIn(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigation()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _carController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(_nameController, 'Full Name', Icons.person),
            _buildTextField(_emailController, 'Email', Icons.email),
            _buildTextField(_passwordController, 'Password', Icons.lock, obscure: true),
            Row(
              children: [
                Expanded(child: _buildTextField(_heightController, 'Height (cm)', Icons.height)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight)),
              ],
            ),
            _buildTextField(_nationalityController, 'Nationality', Icons.flag),
            _buildTextField(_countryController, 'Country', Icons.public),
            _buildTextField(_cityController, 'City', Icons.location_city),
            _buildTextField(_carController, 'Car Model (or "Other")', Icons.directions_car),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                try {
                  final profile = UserProfile(
                    id: '',
                    fullName: _nameController.text,
                    heightCm: _heightController.text,
                    weightKg: _weightController.text,
                    nationality: _nationalityController.text,
                    country: _countryController.text,
                    city: _cityController.text,
                    car: _carController.text.isEmpty ? 'Other' : _carController.text,
                    createdAt: DateTime.now(),
                  );
                  await context.read<SupabaseService>().signUp(
                        _emailController.text,
                        _passwordController.text,
                        profile,
                        _imageFile,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account created! Please check your email.')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const LeaderboardScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1E2A3A),
            unselectedItemColor: const Color(0xFF90A4AE),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 28),
                activeIcon: Icon(Icons.dashboard_rounded, size: 32),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded, size: 28),
                activeIcon: Icon(Icons.map_rounded, size: 32),
                label: 'Maps',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_rounded, size: 28),
                activeIcon: Icon(Icons.emoji_events_rounded, size: 32),
                label: 'Global',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_rounded, size: 28),
                activeIcon: Icon(Icons.analytics_rounded, size: 32),
                label: 'Stats',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
