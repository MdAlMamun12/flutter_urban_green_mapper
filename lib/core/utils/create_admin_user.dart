import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';

class AdminUserCreator {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create an initial admin user (run this once during setup)
  Future<void> createInitialAdminUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🛠️ Creating initial admin user: $email');
      
      // Create user in Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin user document in Firestore
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

      print('✅ Admin user created successfully: $email');
      print('👤 User ID: ${credential.user!.uid}');
      print('🎯 Role: admin');
      
    } catch (e) {
      print('❌ Failed to create admin user: $e');
      rethrow;
    }
  }

  /// Promote an existing user to admin role
  Future<void> promoteUserToAdmin(String userId) async {
    try {
      print('🛠️ Promoting user to admin: $userId');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'role': 'admin',
            'updatedAt': DateTime.now().toIso8601String(),
          });

      print('✅ User promoted to admin successfully: $userId');
      
    } catch (e) {
      print('❌ Failed to promote user to admin: $e');
      rethrow;
    }
  }

  /// Check if admin user exists
  Future<bool> checkAdminUserExists() async {
    try {
      final adminUsers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      return adminUsers.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking admin user existence: $e');
      return false;
    }
  }

  /// Get all admin users
  Future<List<UserModel>> getAdminUsers() async {
    try {
      final adminUsersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return adminUsersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error getting admin users: $e');
      return [];
    }
  }
}