import 'package:flutter/material.dart';

/// Shared Dashboard color constants and helpers.
/// Moved out of `ngo_dashboard.dart` so other widgets can reference it
/// without creating circular imports.
class DashboardColors {
  // Constant colors (hex where possible)
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryWhite = Colors.white;
  static const Color primaryGrey = Colors.grey;
  static const Color primaryRed = Colors.red;
  static const Color primaryBlue = Colors.blue;
  static const Color primaryOrange = Colors.orange;
  static const Color primaryPurple = Colors.purple;
  static const Color primaryTeal = Colors.teal;
  static const Color primaryIndigo = Colors.indigo;
  static const Color primaryAmber = Colors.amber;
  
  // Status colors
  static const Color statusUpcoming = Colors.blue;
  static const Color statusOngoing = Colors.green;
  static const Color statusCompleted = Colors.grey;
  static const Color statusCancelled = Colors.red;
  
  // Tier colors
  static const Color tierPlatinum = Colors.blueGrey;
  static const Color tierGold = Colors.amber;
  static const Color tierSilver = Colors.grey;
  static const Color tierBronze = Colors.orange;
  
  // Safe color getters that never return null
  static Color safeGrey(int shade) {
    final color = Colors.grey[shade];
    return color ?? Colors.grey;
  }
  
  static Color safeGreen(int shade) {
    final color = Colors.green[shade];
    return color ?? Colors.green;
  }
  
  static Color safeBlue(int shade) {
    final color = Colors.blue[shade];
    return color ?? Colors.blue;
  }
  
  static Color safeOrange(int shade) {
    final color = Colors.orange[shade];
    return color ?? Colors.orange;
  }
  
  static Color safeRed(int shade) {
    final color = Colors.red[shade];
    return color ?? Colors.red;
  }
  
  static Color safePurple(int shade) {
    final color = Colors.purple[shade];
    return color ?? Colors.purple;
  }
  
  // Helper method to ensure non-null color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Helper to safely convert num to double for progress values
  static double safeDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }
}