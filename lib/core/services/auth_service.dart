import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final DatabaseService _databaseService = DatabaseService();
  
  // Stream to track user authentication state
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Get user ID
  String? get userId => _auth.currentUser?.uid;
  
  // Get user email
  String? get userEmail => _auth.currentUser?.email;
  
  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;
  
  // Get user photo URL
  String? get userPhotoURL => _auth.currentUser?.photoURL;
  
  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  
  // Get authentication provider
  String get authProvider {
    final user = _auth.currentUser;
    if (user != null && user.providerData.isNotEmpty) {
      return user.providerData.first.providerId;
    }
    return 'unknown';
  }
  
  // Check if user signed in with Google
  bool get isGoogleUser => authProvider == 'google.com';
  
  // Check if user signed in with email/password
  bool get isEmailUser => authProvider == 'password';
  
  // ADMIN LOGIN METHOD - Only allows users with 'admin' role
  Future<UserModel> adminLoginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      User? user = result.user;
      
      if (user != null) {
        // Get user data from Firestore
        UserModel userModel = await _databaseService.getUser(user.uid);
        
        // Check if user has admin role
        if (userModel.role != 'admin') {
          // Sign out non-admin users immediately
          await _auth.signOut();
          throw AuthException('Access denied. Admin privileges required.');
        }
        
        return userModel;
      } else {
        throw AuthException('Failed to sign in - no user returned');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }
  
  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      User? user = result.user;
      
      if (user != null) {
        // Get user data from Firestore
        return await _databaseService.getUser(user.uid);
      } else {
        throw AuthException('Failed to sign in - no user returned');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }
  
  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword(
    String email, 
    String password, 
    String name,
    String role
  ) async {
    try {
      // Prevent admin registration through normal signup
      if (role == 'admin') {
        throw AuthException('Admin accounts cannot be created through public registration.');
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      User? user = result.user;
      
      if (user != null) {
        // Create user in Firestore
        UserModel newUser = UserModel(
          userId: user.uid,
          name: name,
          email: email,
          role: role,
          location: null,
          impactScore: 0,
          createdAt: DateTime.now(),
        );
        
        await _databaseService.createUser(newUser);
        return newUser;
      } else {
        throw AuthException('Failed to register - no user returned');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to register: $e');
    }
  }

  // SPONSOR REGISTRATION METHOD
  Future<UserModel> registerSponsorWithEmailAndPassword({
    required String email,
    required String password,
    required String organizationName,
    required String organizationType,
    required String contactPerson,
    required String sponsorTier,
    String? website,
    String? phoneNumber,
    String? businessAddress,
    String? taxId,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      User? user = result.user;
      
      if (user != null) {
        // Create sponsor user in Firestore
        UserModel newSponsor = UserModel(
          userId: user.uid,
          name: contactPerson,
          email: email,
          role: 'sponsor',
          location: null,
          impactScore: 0,
          createdAt: DateTime.now(),
          organizationName: organizationName,
          organizationType: organizationType,
          contactPerson: contactPerson,
          sponsorTier: sponsorTier,
          website: website,
          phoneNumber: phoneNumber,
          businessAddress: businessAddress,
          taxId: taxId,
          isActiveSponsor: true,
          sponsorSince: DateTime.now(),
          totalContribution: 0.0,
          sponsoredEvents: [],
        );
        
        await _databaseService.createSponsorUser(newSponsor);
        return newSponsor;
      } else {
        throw AuthException('Failed to register sponsor - no user returned');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to register sponsor: $e');
    }
  }

  // UPGRADE USER TO SPONSOR
  Future<UserModel> upgradeUserToSponsor({
    required String userId,
    required String organizationName,
    required String organizationType,
    required String contactPerson,
    required String sponsorTier,
    String? website,
    String? businessAddress,
    String? taxId,
  }) async {
    try {
      await _databaseService.upgradeUserToSponsor(
        userId: userId,
        organizationName: organizationName,
        organizationType: organizationType,
        contactPerson: contactPerson,
        sponsorTier: sponsorTier,
        website: website,
        businessAddress: businessAddress,
        taxId: taxId,
      );
      
      // Return updated user
      return await _databaseService.getUser(userId);
    } catch (e) {
      throw AuthException('Failed to upgrade user to sponsor: $e');
    }
  }

  // UPDATE SPONSOR PROFILE
  Future<UserModel> updateSponsorProfile({
    required String userId,
    String? organizationName,
    String? organizationType,
    String? website,
    String? contactPerson,
    String? sponsorTier,
    String? businessAddress,
    String? taxId,
    String? paymentMethod,
  }) async {
    try {
      await _databaseService.updateSponsorProfile(
        userId: userId,
        organizationName: organizationName,
        organizationType: organizationType,
        website: website,
        contactPerson: contactPerson,
        sponsorTier: sponsorTier,
        businessAddress: businessAddress,
        taxId: taxId,
        paymentMethod: paymentMethod,
      );
      
      // Return updated user
      return await _databaseService.getUser(userId);
    } catch (e) {
      throw AuthException('Failed to update sponsor profile: $e');
    }
  }

  // UPDATE SPONSOR CONTRIBUTION
  Future<UserModel> updateSponsorContribution({
    required String userId,
    required double amount,
  }) async {
    try {
      await _databaseService.updateSponsorContribution(userId, amount);
      
      // Return updated user
      return await _databaseService.getUser(userId);
    } catch (e) {
      throw AuthException('Failed to update sponsor contribution: $e');
    }
  }

  // ADD SPONSORED EVENT
  Future<UserModel> addSponsoredEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _databaseService.addSponsoredEvent(userId, eventId);
      
      // Return updated user
      return await _databaseService.getUser(userId);
    } catch (e) {
      throw AuthException('Failed to add sponsored event: $e');
    }
  }

  // UPGRADE SPONSOR TIER
  Future<UserModel> upgradeSponsorTier({
    required String userId,
    required String newTier,
  }) async {
    try {
      await _databaseService.upgradeSponsorTier(userId, newTier);
      
      // Return updated user
      return await _databaseService.getUser(userId);
    } catch (e) {
      throw AuthException('Failed to upgrade sponsor tier: $e');
    }
  }

  // MANAGE SPONSOR STATUS (ADMIN ONLY)
  Future<void> manageSponsorStatus({
    required String sponsorId,
    required bool activate,
    String? reason,
    required String adminId,
  }) async {
    try {
      await _databaseService.manageSponsorStatus(
        sponsorId: sponsorId,
        activate: activate,
        reason: reason,
        adminId: adminId,
      );
    } catch (e) {
      throw AuthException('Failed to manage sponsor status: $e');
    }
  }

  // GET ALL SPONSORS (ADMIN ONLY)
  Future<List<UserModel>> getAllSponsors() async {
    try {
      return await _databaseService.getAllSponsors();
    } catch (e) {
      throw AuthException('Failed to get all sponsors: $e');
    }
  }

  // GET SPONSORS BY TIER
  Future<List<UserModel>> getSponsorsByTier(String tier) async {
    try {
      return await _databaseService.getSponsorsByTier(tier);
    } catch (e) {
      throw AuthException('Failed to get sponsors by tier: $e');
    }
  }

  // GET ACTIVE SPONSORS
  Future<List<UserModel>> getActiveSponsors() async {
    try {
      return await _databaseService.getActiveSponsors();
    } catch (e) {
      throw AuthException('Failed to get active sponsors: $e');
    }
  }
  
  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }
      
      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credentials
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with Google credentials
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      
      if (user != null) {
        // Check if user exists in Firestore
        try {
          UserModel userModel = await _databaseService.getUser(user.uid);
          
          // Prevent non-admin users from accessing admin features via Google
          if (userModel.role == 'admin') {
            throw AuthException('Admin accounts must use email/password login for security.');
          }
          
          return userModel;
        } catch (e) {
          // User doesn't exist, create new user (default to citizen)
          UserModel newUser = UserModel(
            userId: user.uid,
            name: user.displayName ?? googleUser.displayName ?? 'User',
            email: user.email ?? googleUser.email,
            role: 'citizen', // Default role for Google sign-in
            location: null,
            impactScore: 0,
            createdAt: DateTime.now(),
          );
          
          await _databaseService.createUser(newUser);
          return newUser;
        }
      } else {
        throw AuthException('Failed to sign in with Google');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to sign in with Google: $e');
    }
  }
  
  // Sign out - FIXED VERSION
  Future<void> signOut() async {
    try {
      // Always sign out from Firebase first (most important)
      await _auth.signOut();
      
      // Then try to sign out from Google (non-critical operation)
      try {
        // Check if Google Sign-In is available and user is signed in
        final isSignedIn = await _googleSignIn.isSignedIn();
        if (isSignedIn) {
          await _googleSignIn.signOut();
        }
      } catch (e) {
        // Non-critical error - log but don't throw
        print('⚠️ Google Sign-Out non-critical issue: $e');
        // Continue with logout process
      }
      
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      // If Firebase sign out fails, rethrow the error
      throw AuthException('Failed to sign out: $e');
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to reset password: $e');
    }
  }
  
  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        
        // Also update in Firestore
        final updates = <String, dynamic>{};
        if (displayName != null) updates['name'] = displayName;
        if (photoURL != null) updates['photo_url'] = photoURL;
        
        if (updates.isNotEmpty) {
          await _databaseService.updateUser(user.uid, updates);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to update profile: $e');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        
        // Update email in Firestore
        await _databaseService.updateUser(user.uid, {'email': newEmail});
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to update email: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to update password: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore first
        await _databaseService.deleteUserData(user.uid);
        
        // Try to sign out from Google if connected (non-critical)
        try {
          if (await _googleSignIn.isSignedIn()) {
            await _googleSignIn.disconnect();
          }
        } catch (e) {
          print('⚠️ Google disconnect non-critical: $e');
          // Continue with account deletion
        }
        
        // Then delete auth account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to send email verification: $e');
    }
  }

  // Reload user (to refresh email verification status)
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw AuthException('Failed to reload user: $e');
    }
  }

  // Check if Google Sign In is available
  Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _googleSignIn.canAccessScopes([]);
    } catch (e) {
      return false;
    }
  }

  // Get user token (for API calls)
  Future<String?> getUserToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  // Check if user needs reauthentication
  Future<bool> needsReauthentication() async {
    try {
      final token = await getUserToken();
      return token == null;
    } catch (e) {
      return true;
    }
  }

  // Re-authenticate user (for sensitive operations)
  Future<void> reauthenticateWithCredential(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to reauthenticate: $e');
    }
  }

  // Re-authenticate Google user
  Future<void> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) {
        throw AuthException('Google reauthentication failed');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to reauthenticate with Google: $e');
    }
  }
  
  // Get user data
  Future<UserModel> getUser(String userId) async {
    try {
      return await _databaseService.getUser(userId);
    } catch (e) {
      throw AuthException('Failed to get user: $e');
    }
  }

  // Handle Firebase Auth exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return EmailAlreadyInUseException();
      case 'invalid-email':
        return InvalidEmailException();
      case 'wrong-password':
        return WrongPasswordException();
      case 'user-not-found':
        return UserNotFoundException();
      case 'weak-password':
        return WeakPasswordException();
      case 'network-request-failed':
        return NetworkRequestFailedException();
      case 'user-disabled':
        return UserDisabledException();
      case 'too-many-requests':
        return TooManyRequestsException();
      case 'operation-not-allowed':
        return OperationNotAllowedException();
      case 'account-exists-with-different-credential':
        return AccountExistsWithDifferentCredentialException();
      case 'requires-recent-login':
        return RequiresRecentLoginException();
      default:
        return AuthException(e.message ?? 'Authentication failed', code: e.code);
    }
  }
}

// Authentication exceptions
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {this.code = 'unknown'});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException() : super('Email is already in use', code: 'email-already-in-use');
}

class InvalidEmailException extends AuthException {
  InvalidEmailException() : super('Invalid email address', code: 'invalid-email');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException() : super('Wrong password', code: 'wrong-password');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('User not found', code: 'user-not-found');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException() : super('Password is too weak', code: 'weak-password');
}

class NetworkRequestFailedException extends AuthException {
  NetworkRequestFailedException() : super('Network request failed', code: 'network-request-failed');
}

class UserDisabledException extends AuthException {
  UserDisabledException() : super('User account has been disabled', code: 'user-disabled');
}

class TooManyRequestsException extends AuthException {
  TooManyRequestsException() : super('Too many requests. Please try again later.', code: 'too-many-requests');
}

class OperationNotAllowedException extends AuthException {
  OperationNotAllowedException() : super('Operation not allowed', code: 'operation-not-allowed');
}

class AccountExistsWithDifferentCredentialException extends AuthException {
  AccountExistsWithDifferentCredentialException() : super('Account exists with different credential', code: 'account-exists-with-different-credential');
}

class RequiresRecentLoginException extends AuthException {
  RequiresRecentLoginException() : super('This operation requires recent authentication. Please log in again.', code: 'requires-recent-login');
}

// Sponsor-specific exceptions
class SponsorRegistrationException extends AuthException {
  SponsorRegistrationException(String message) : super(message, code: 'sponsor-registration-failed');
}

class SponsorUpgradeException extends AuthException {
  SponsorUpgradeException(String message) : super(message, code: 'sponsor-upgrade-failed');
}

class SponsorNotActiveException extends AuthException {
  SponsorNotActiveException() : super('Sponsor account is not active', code: 'sponsor-not-active');
}

class InsufficientTierRequirementsException extends AuthException {
  InsufficientTierRequirementsException() : super('Sponsor does not meet tier requirements', code: 'insufficient-tier-requirements');
}