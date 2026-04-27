import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:location/location.dart' as loc;
import 'models/user_profile.dart';
import 'services/supabase_service.dart';
import 'services/weather_service.dart';
import 'services/ai_service.dart';
import 'services/notification_service.dart';
import 'services/ride_hailing_service.dart';
import 'screens/home_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  await Supabase.initialize(
    url: 'https://gzwciujlrsaoxunqjojl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd6d2NpdWpscnNhb3h1bnFqb2psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MTUxOTcsImV4cCI6MjA5MjE5MTE5N30.SRFiSebyzaK4J5nf0arK4Hg8xWvSZHzBdgGZV98jtwo',
  );

  // Initialize Services
  final weatherService = WeatherService();
  final aiService = AiService();

  // Schedule daily notification with location-based weather
  _setupDailyNotification(notificationService, weatherService, aiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(create: (_) => SupabaseService()),
        Provider<WeatherService>(create: (_) => weatherService),
        Provider<AiService>(create: (_) => aiService),
        Provider<NotificationService>(create: (_) => notificationService),
        Provider<RideHailingService>(create: (_) => RideHailingService()),
      ],
      child: const FootpryntApp(),
    ),
  );
}

Future<void> _setupDailyNotification(
  NotificationService notificationService,
  WeatherService weatherService,
  AiService aiService,
) async {
  try {
    final location = loc.Location();
    final locData = await location.getLocation();
    final weather = await weatherService.getWeather(locData.latitude!, locData.longitude!);
    final message = aiService.getMorningNotification(weather);
    
    await notificationService.scheduleDaily6AmNotification(
      'Rise and Shine!',
      message,
    );
  } catch (e) {
    // Default fallback if location or weather fails
    await notificationService.scheduleDaily6AmNotification(
      'Good morning!',
      'Check out your personalized eco-tip for today to reduce your footprint!',
    );
  }
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
          seedColor: const Color(0xFF6B8E6B), // Deeper Sage
          primary: const Color(0xFF4A674A), // Muted Forest
          secondary: const Color(0xFF98B498), // Soft Sage
          tertiary: const Color(0xFFF1F5F1), // Off-white Mist
          surface: const Color(0xFFFFFFFF),
          error: const Color(0xFFD63031),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF7F9F7), // Very subtle green tint background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(color: Color(0xFF4A674A), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          prefixIconColor: const Color(0xFF4A674A),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          color: Colors.white,
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.tertiary,
              theme.colorScheme.surface,
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Animated Blobs with Logo Colors
            Positioned(
              top: -100,
              right: -50,
              child: _buildBlob(theme.colorScheme.primary.withValues(alpha: 0.08), 400)
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 8.seconds, curve: Curves.easeInOut)
                  .rotate(begin: 0, end: 0.05),
            ),
            Positioned(
              bottom: -50,
              left: -100,
              child: _buildBlob(theme.colorScheme.secondary.withValues(alpha: 0.05), 350)
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: 0, end: 50, duration: 10.seconds, curve: Curves.easeInOut)
                  .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 7.seconds),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with Neumorphic/Soft Shadow
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.05),
                              blurRadius: 50,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 20,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Image.asset('assets/logo/logo.png', width: 130, height: 130),
                      ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),

                      const SizedBox(height: 56),

                      // Refined Title Section
                      Column(
                        children: [
                          Text(
                            'Footprynt',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                              letterSpacing: -2.5,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'TRACK • REDUCE • IMPACT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 80),

                      // Modern Action Buttons
                      Column(
                        children: [
                          // Primary Google Button
                          _buildPrimaryButton(
                            context,
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
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, size: 36),
                                SizedBox(width: 8),
                                Text('Continue with Google'),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Glassmorphic Email Button
                          _buildGlassButton(
                            context,
                            label: 'Sign In with Email',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Custom Styled Footer Text
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                                children: [
                                  const TextSpan(text: "New to Footprynt? "),
                                  TextSpan(
                                    text: "Join us now",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, {required VoidCallback onPressed, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildGlassButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
          ),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 22),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: -1.5,
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Text(
                'Continue your journey to a greener\nplanet with us.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 60),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05, end: 0),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05, end: 0),
              const SizedBox(height: 48),
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
                        SnackBar(
                          content: Text('Error: $e'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Go Back',
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w700),
                ),
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
  bool _isLoading = false;

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
        title: const Text('Join the Community'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
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
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: theme.colorScheme.tertiary,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? Icon(Icons.add_a_photo_outlined, size: 36, color: theme.colorScheme.primary)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 56),
            _buildTextField(_nameController, 'Full Name', Icons.person_outline_rounded),
            _buildTextField(_emailController, 'Email Address', Icons.email_outlined),
            _buildTextField(_passwordController, 'Create Password', Icons.lock_outline_rounded, obscure: true),
            Row(
              children: [
                Expanded(child: _buildTextField(_heightController, 'Height (cm)', Icons.height_rounded)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined)),
              ],
            ),
            _buildTextField(_nationalityController, 'Nationality', Icons.flag_outlined),
            _buildTextField(_countryController, 'Country', Icons.public_outlined),
            _buildTextField(_cityController, 'City', Icons.location_city_outlined),
            _buildTextField(_carController, 'Car Model (Optional)', Icons.directions_car_outlined),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
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
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        profile,
                        _imageFile,
                      );
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        title: const Text('Account Created!', style: TextStyle(fontWeight: FontWeight.w900)),
                        content: const Text(
                          'Welcome aboard! Please check your email for a confirmation link to activate your account.',
                          style: TextStyle(height: 1.5, fontWeight: FontWeight.w500),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to login/welcome
                            },
                            child: Text('Got it', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 16)),
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
                        backgroundColor: theme.colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 22),
              ),
              child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 24),
        ),
      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0),
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
