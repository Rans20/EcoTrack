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
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd6d2NpdWpscnNhb3h1bnFqb2psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MTUxOTcsImV4cCI6MjA5MjE5MTE5N30.SRFiSebyzaK4J5nf0arK4Hg8xWvSZHzBdgGZV98jtwo',
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
          seedColor: const Color(0xFF6B8E23), // Olive/Sage Green
          primary: const Color(0xFF4A6D4A), // Muted Forest
          secondary: const Color(0xFF8DAA8D), // Soft Sage
          tertiary: const Color(0xFFD9E2D9), // Pale Mist
          surface: const Color(0xFFF9FBF9), // Warm White
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF9FBF9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4A6D4A), width: 2),
          ),
        ),
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
              theme.colorScheme.tertiary.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/logo/logo.png', width: 140, height: 140),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Footprynt',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const Text(
                    'TRACK • REDUCE • IMPACT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF636E72),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: Divider()),
                    ],
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue your eco journey',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 32),
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
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
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
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.tertiary,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? Icon(Icons.camera_alt_outlined, size: 40, color: theme.colorScheme.primary)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            _buildTextField(_nameController, 'Full Name', Icons.person_outline),
            _buildTextField(_emailController, 'Email', Icons.email_outlined),
            _buildTextField(_passwordController, 'Password', Icons.lock_outline, obscure: true),
            Row(
              children: [
                Expanded(child: _buildTextField(_heightController, 'Height (cm)', Icons.height)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined)),
              ],
            ),
            _buildTextField(_nationalityController, 'Nationality', Icons.flag_outlined),
            _buildTextField(_countryController, 'Country', Icons.public_outlined),
            _buildTextField(_cityController, 'City', Icons.location_city_outlined),
            _buildTextField(_carController, 'Car Model (or "Other")', Icons.directions_car_outlined),
            const SizedBox(height: 32),
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
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: const Text('Account Created'),
                        content: const Text(
                          'Your account has been created successfully! Please check your email for a confirmation link before signing in.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to login/welcome
                            },
                            child: Text('OK', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22),
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
    final theme = Theme.of(context);
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: const Color(0xFFB2BEC3),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 24),
              activeIcon: Icon(Icons.dashboard_rounded, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined, size: 24),
              activeIcon: Icon(Icons.map_rounded, size: 28),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined, size: 24),
              activeIcon: Icon(Icons.emoji_events_rounded, size: 28),
              label: 'Impact',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined, size: 24),
              activeIcon: Icon(Icons.analytics_rounded, size: 28),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
