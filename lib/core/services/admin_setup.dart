import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';

class AdminSetup {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Comprehensive admin setup - creates admin user and sets up initial data
  Future<void> setupAdminEnvironment({
    required String adminEmail,
    required String adminPassword,
    required String adminName,
  }) async {
    try {
      print('🚀 Starting admin environment setup...');
      
      // Check if admin user already exists
      final adminExists = await _checkAdminUserExists();
      if (adminExists) {
        print('ℹ️ Admin user already exists, skipping creation');
        return;
      }

      // Create admin user
      await _createAdminUser(
        email: adminEmail,
        password: adminPassword,
        name: adminName,
      );

      // Setup initial admin data
      await _setupInitialAdminData();

      print('✅ Admin environment setup completed successfully');
      
    } catch (e) {
      print('❌ Admin setup failed: $e');
      rethrow;
    }
  }

  Future<bool> _checkAdminUserExists() async {
    try {
      final adminUsers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      return adminUsers.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _createAdminUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel adminUser = UserModel(
        userId: credential.user!.uid,
        email: email,
        name: name,
        role: 'admin',
        location: null,
        impactScore: 0,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(adminUser.toMap());

      print('✅ Admin user created: $email');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _setupInitialAdminData() async {
    try {
      // Create initial system settings
      await _firestore.collection('system_settings').doc('admin_config').set({
        'createdAt': DateTime.now().toIso8601String(),
        'maxUsers': 1000,
        'maxStorageMB': 1024,
        'featuresEnabled': {
          'userManagement': true,
          'contentModeration': true,
          'analytics': true,
          'systemMaintenance': true,
        },
      });

      print('✅ Initial admin data setup completed');
    } catch (e) {
      print('⚠️ Could not setup initial admin data: $e');
      // Continue even if this fails
    }
  }

  /// Verify admin user credentials
  Future<bool> verifyAdminCredentials(String email, String password) async {
    try {
      // This is just for verification - we'll sign in and immediately sign out
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if the user has admin role
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      
      await _auth.signOut(); // Sign out immediately after verification
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] == 'admin';
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Run this once during app initialization to ensure admin user exists
  static Future<void> ensureAdminUserExists() async {
    final adminSetup = AdminSetup();
    final adminExists = await adminSetup._checkAdminUserExists();
    
    if (!adminExists) {
      print('⚠️ No admin user found. Please run setupAdminEnvironment()');
    } else {
      print('✅ Admin user verification: OK');
    }
  }
}