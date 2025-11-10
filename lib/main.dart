import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/dashboard_provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/admin_dashboard_provider.dart';
import 'package:urban_green_mapper/features/dashboard/screens/citizen_dashboard.dart';
import 'package:urban_green_mapper/features/dashboard/screens/ngo_dashboard.dart';
import 'package:urban_green_mapper/features/dashboard/screens/admin_dashboard.dart';
import 'package:urban_green_mapper/features/auth/screens/login_screen.dart';
import 'package:urban_green_mapper/features/auth/screens/signup_screen.dart';
import 'package:urban_green_mapper/features/auth/screens/registration_screen.dart';
import 'package:urban_green_mapper/features/auth/screens/admin_login_screen.dart';
import 'package:urban_green_mapper/features/events/providers/events_provider.dart';
import 'package:urban_green_mapper/features/mapping/providers/map_provider.dart';
import 'package:urban_green_mapper/features/profile/providers/profile_provider.dart';
import 'package:urban_green_mapper/features/reports/providers/report_provider.dart';
import 'package:urban_green_mapper/features/adoption/providers/adoption_provider.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';
import 'package:urban_green_mapper/core/services/auth_service.dart';
import 'package:urban_green_mapper/core/services/location_service.dart';
import 'package:urban_green_mapper/core/services/notification_service.dart';
import 'package:urban_green_mapper/core/services/storage_service.dart';
import 'package:urban_green_mapper/core/services/pdf_export_service.dart';
import 'package:urban_green_mapper/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting Firebase initialization...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    // Continue anyway - some features might work without Firebase
  }
  
  // Initialize export service at app start
  try {
    await PdfExportService().initialize();
    print('✅ PDF Export service initialized successfully');
  } catch (e) {
    print('⚠️ PDF Export service initialization warning: $e');
    // Continue anyway - it will try to initialize again when needed
  }
  
  runApp(
    MultiProvider(
      providers: [
        // Auth and User Providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        
        // Dashboard Providers
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => NGODashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        
        // Feature Providers
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => AdoptionProvider()),
        
        // Core Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        
        // Export Services
        Provider<PdfExportService>(create: (_) => PdfExportService()),
      ],
      child: const UrbanGreenMapperApp(),
    ),
  );
}

class UrbanGreenMapperApp extends StatelessWidget {
  const UrbanGreenMapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building UrbanGreenMapperApp');
    return MaterialApp(
      title: 'Urban Green Mapper',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const AppWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/signup': (context) => const SignupScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/citizen-dashboard': (context) => const CitizenDashboard(),
        '/ngo-dashboard': (context) => const NGODashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isInitializing = true;
  bool _initializationError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🔄 AppWrapper initState called');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 AppWrapper: Starting app initialization...');
      
      // Initialize services with error handling
      try {
        final notificationService = NotificationService();
        await notificationService.init();
        print('✅ Notification service initialized');
      } catch (e) {
        print('⚠️ Notification service initialization warning: $e');
        // Continue even if notifications fail
      }
      
      try {
        final locationService = LocationService();
        await locationService.init();
        print('✅ Location service initialized');
      } catch (e) {
        print('⚠️ Location service initialization warning: $e');
        // Continue even if location fails
      }
      
      try {
        final storageService = StorageService();
        await storageService.initialize();
        print('✅ Storage service initialized');
      } catch (e) {
        print('⚠️ Storage service initialization warning: $e');
        // Continue even if storage fails
      }
      
      try {
        final pdfExportService = PdfExportService();
        await pdfExportService.initialize();
        print('✅ PDF Export service initialized');
      } catch (e) {
        print('⚠️ PDF Export service initialization warning: $e');
        // Continue even if export service fails
      }
      
      // Initialize auth provider and check current user
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.initialize();
        print('✅ Auth provider initialized');
        
        // Check if user is properly loaded
        if (authProvider.user != null) {
          print('👤 User found after initialization: ${authProvider.user?.name} (${authProvider.user?.role})');
        } else {
          print('👤 No user found after initialization');
        }
      } catch (e) {
        print('❌ Auth provider initialization error: $e');
        _initializationError = true;
        _errorMessage = 'Authentication service unavailable: $e';
      }
      
      print('✅ All services initialized successfully');
      
    } catch (e) {
      print('❌ App initialization error: $e');
      _initializationError = true;
      _errorMessage = 'Failed to initialize app: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      print('🏁 App initialization completed. _isInitializing: false');
    }
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _initializationError = false;
      _errorMessage = null;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 AppWrapper build called. _isInitializing: $_isInitializing, _initializationError: $_initializationError');
    
    if (_isInitializing) {
      print('📱 Showing SplashScreen');
      return const SplashScreen();
    }

    if (_initializationError) {
      print('❌ Showing ErrorScreen');
      return ErrorScreen(
        errorMessage: _errorMessage ?? 'Unknown error occurred',
        onRetry: _retryInitialization,
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('👤 AppWrapper - AuthProvider state:');
        print('   - isLoading: ${authProvider.isLoading}');
        print('   - user: ${authProvider.user?.name ?? "null"}');
        print('   - role: ${authProvider.user?.role ?? "null"}');
        print('   - userId: ${authProvider.user?.userId ?? "null"}');
        print('   - isLoggedIn: ${authProvider.isLoggedIn}');
        print('   - isAdmin: ${authProvider.isAdmin}');
        print('   - isNGO: ${authProvider.isNGO}');
        print('   - isCitizen: ${authProvider.isCitizen}');
        print('   - isSponsor: ${authProvider.isSponsor}');
        
        if (authProvider.isLoading) {
          print('⏳ AuthProvider is loading, showing SplashScreen');
          return const SplashScreen();
        }

        // Check if user is logged in and has valid data
        if (authProvider.isLoggedIn && authProvider.user != null) {
          // User is logged in - navigate to appropriate dashboard
          print('📱 User logged in, navigating to dashboard based on role: ${authProvider.user?.role}');
          print('🎯 Dashboard type: ${_getDashboardType(authProvider.user!.role)}');
          
          // Add a small delay to ensure proper navigation
          Future.delayed(Duration.zero, () {
            // This ensures the navigation happens after the build is complete
          });
          
          return _getDashboardForRole(authProvider.user!.role);
        } else {
          // User is not logged in - show login screen
          print('📱 No user logged in, showing LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }

  Widget _getDashboardForRole(String role) {
    print('🎯 _getDashboardForRole called with role: $role');
    
    switch (role) {
      case 'admin':
        print('👑 Redirecting to AdminDashboard');
        return const AdminDashboard();
      case 'ngo':
        print('🏢 Redirecting to NGODashboard');
        return const NGODashboard();
      case 'citizen':
        print('👤 Redirecting to CitizenDashboard');
        return const CitizenDashboard();
      case 'sponsor':
        print('🏢 Redirecting to CitizenDashboard (Sponsors use Citizen UI)');
        return const CitizenDashboard();
      default:
        print('❓ Unknown role "$role", defaulting to CitizenDashboard');
        return const CitizenDashboard();
    }
  }

  String _getDashboardType(String role) {
    switch (role) {
      case 'admin': return 'AdminDashboard';
      case 'ngo': return 'NGODashboard';
      case 'citizen': return 'CitizenDashboard';
      case 'sponsor': return 'CitizenDashboard';
      default: return 'Unknown';
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building SplashScreen');
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            Text(
              'Urban Green Mapper',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connecting Communities with Green Spaces',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Error Title
              Text(
                'Initialization Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Error Message
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Retry Button
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(height: 16),
              // Alternative: Continue without services
              TextButton(
                onPressed: () {
                  // Continue to login screen even with errors
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'Continue Anyway',
                  style: TextStyle(
                    color: Colors.green[700],
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

// Fallback widget if any screen fails to load
class FallbackScreen extends StatelessWidget {
  final String message;

  const FallbackScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urban Green Mapper'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber,
                size: 64,
                color: Colors.orange[700],
              ),
              const SizedBox(height: 24),
              Text(
                'Temporary Issue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}