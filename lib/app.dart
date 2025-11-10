import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/features/dashboard/screens/citizen_dashboard.dart';
import 'package:urban_green_mapper/features/auth/screens/login_screen.dart';

class UrbanGreenMapper extends StatelessWidget {
  const UrbanGreenMapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here
      ],
      child: MaterialApp(
        title: 'Urban Green Mapper',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.user != null) {
              // Based on user role, show appropriate dashboard
              return const CitizenDashboard(); // Replace with role-based routing
            } else {
              return const LoginScreen();
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}