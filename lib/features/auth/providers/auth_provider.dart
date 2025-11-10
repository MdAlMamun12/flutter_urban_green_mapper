import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';
import 'package:urban_green_mapper/core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize auth state
  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      debugPrint('AuthProvider: Setting up auth state listener');
      
      _authService.user.listen((User? firebaseUser) async {
        debugPrint('AuthProvider: Auth state changed - User: ${firebaseUser?.uid}');
        
        if (firebaseUser != null) {
          try {
            debugPrint('AuthProvider: Fetching user data from Firestore...');
            _user = await _authService.getUser(firebaseUser.uid);
            debugPrint('AuthProvider: User data loaded successfully: ${_user?.name}, Role: ${_user?.role}');
          } catch (e) {
            _error = 'Failed to get user data: $e';
            debugPrint('AuthProvider: Error fetching user data: $e');
            _user = null;
          }
        } else {
          debugPrint('AuthProvider: No user logged in');
          _user = null;
        }
        notifyListeners();
      });
      
      debugPrint('AuthProvider: Auth state listener setup completed');
    } catch (e) {
      debugPrint('AuthProvider: Error setting up auth listener: $e');
      _error = 'Failed to setup auth listener: $e';
    }
  }

  // Initialize method for main.dart
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      debugPrint('AuthProvider: Starting initialization...');
      
      // Check if user is already logged in
      if (_authService.currentUser != null) {
        debugPrint('AuthProvider: User found in Firebase Auth: ${_authService.currentUser!.uid}');
        try {
          _user = await _authService.getUser(_authService.currentUser!.uid);
          debugPrint('AuthProvider: User data loaded: ${_user?.name} (Role: ${_user?.role})');
        } catch (e) {
          debugPrint('AuthProvider: Error loading user data: $e');
          _user = null;
          _error = 'Failed to load user data: $e';
        }
      } else {
        debugPrint('AuthProvider: No user found in Firebase Auth');
        _user = null;
      }
      
      debugPrint('AuthProvider: Initialization completed successfully');
      
    } catch (e) {
      debugPrint('AuthProvider: Initialization error: $e');
      _error = 'Failed to initialize auth: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ADMIN LOGIN METHOD
  Future<bool> adminLogin(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🛡️ AuthProvider: Attempting ADMIN login for: $email');
      
      _user = await _authService.adminLoginWithEmailAndPassword(email, password);
      
      debugPrint('✅ AuthProvider: Admin login SUCCESSFUL: ${_user?.name}');
      debugPrint('🎯 AuthProvider: User role: ${_user?.role}');
      debugPrint('🆔 AuthProvider: User ID: ${_user?.userId}');
      debugPrint('📧 AuthProvider: User email: ${_user?.email}');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      _user = null;
      debugPrint('❌ AuthProvider: Admin login failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // REGULAR LOGIN METHOD
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🔐 AuthProvider: Attempting regular login for: $email');
      
      _user = await _authService.signInWithEmailAndPassword(email, password);
      
      debugPrint('✅ AuthProvider: Regular login SUCCESSFUL: ${_user?.name}');
      debugPrint('🎯 AuthProvider: User role: ${_user?.role}');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      _user = null;
      debugPrint('❌ AuthProvider: Login failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // REGULAR REGISTRATION METHOD
  Future<bool> register(String email, String password, String name, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Attempting registration for: $email, Role: $role');
      
      _user = await _authService.registerWithEmailAndPassword(
        email, 
        password, 
        name, 
        role
      );
      
      debugPrint('AuthProvider: Registration successful: ${_user?.name}');
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      _user = null;
      debugPrint('AuthProvider: Registration failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SPONSOR REGISTRATION METHOD
  Future<bool> registerAsSponsor({
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🏢 AuthProvider: Attempting SPONSOR registration for: $organizationName');
      debugPrint('📧 Email: $email, Tier: $sponsorTier');
      
      _user = await _authService.registerSponsorWithEmailAndPassword(
        email: email,
        password: password,
        organizationName: organizationName,
        organizationType: organizationType,
        contactPerson: contactPerson,
        sponsorTier: sponsorTier,
        website: website,
        phoneNumber: phoneNumber,
        businessAddress: businessAddress,
        taxId: taxId,
      );
      
      debugPrint('✅ AuthProvider: Sponsor registration SUCCESSFUL: ${_user?.organizationName}');
      debugPrint('🎯 AuthProvider: Sponsor tier: ${_user?.sponsorTier}');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      _user = null;
      debugPrint('❌ AuthProvider: Sponsor registration failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPGRADE CITIZEN TO SPONSOR METHOD
  Future<bool> upgradeToSponsor({
    required String organizationName,
    required String organizationType,
    required String contactPerson,
    required String sponsorTier,
    String? website,
    String? businessAddress,
    String? taxId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        throw AuthException('No user logged in');
      }

      if (_user!.isSponsor) {
        throw AuthException('User is already a sponsor');
      }

      debugPrint('🔄 AuthProvider: Upgrading citizen to sponsor: ${_user!.name}');
      debugPrint('🏢 Organization: $organizationName, Tier: $sponsorTier');
      
      _user = await _authService.upgradeUserToSponsor(
        userId: _user!.userId,
        organizationName: organizationName,
        organizationType: organizationType,
        contactPerson: contactPerson,
        sponsorTier: sponsorTier,
        website: website,
        businessAddress: businessAddress,
        taxId: taxId,
      );
      
      debugPrint('✅ AuthProvider: Upgrade to sponsor SUCCESSFUL: ${_user?.organizationName}');
      debugPrint('🎯 AuthProvider: New role: ${_user?.role}, Tier: ${_user?.sponsorTier}');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Upgrade to sponsor failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE SPONSOR PROFILE METHOD
  Future<bool> updateSponsorProfile({
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null || !_user!.isSponsor) {
        throw AuthException('Only sponsor users can update sponsor profile');
      }

      debugPrint('📝 AuthProvider: Updating sponsor profile for: ${_user!.organizationName}');
      
      _user = await _authService.updateSponsorProfile(
        userId: _user!.userId,
        organizationName: organizationName,
        organizationType: organizationType,
        website: website,
        contactPerson: contactPerson,
        sponsorTier: sponsorTier,
        businessAddress: businessAddress,
        taxId: taxId,
        paymentMethod: paymentMethod,
      );
      
      debugPrint('✅ AuthProvider: Sponsor profile updated successfully');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Sponsor profile update failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE SPONSOR CONTRIBUTION METHOD
  Future<bool> updateSponsorContribution(double amount) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null || !_user!.isSponsor) {
        throw AuthException('Only sponsor users can update contributions');
      }

      debugPrint('💰 AuthProvider: Updating sponsor contribution for: ${_user!.organizationName}');
      debugPrint('💵 Amount: \$$amount, Previous total: \$${_user!.totalContribution}');
      
      _user = await _authService.updateSponsorContribution(
        userId: _user!.userId,
        amount: amount,
      );
      
      debugPrint('✅ AuthProvider: Sponsor contribution updated successfully');
      debugPrint('📊 New total contribution: \$${_user!.totalContribution}');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Sponsor contribution update failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ADD SPONSORED EVENT METHOD
  Future<bool> addSponsoredEvent(String eventId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null || !_user!.isSponsor) {
        throw AuthException('Only sponsor users can sponsor events');
      }

      debugPrint('🎯 AuthProvider: Adding sponsored event for: ${_user!.organizationName}');
      debugPrint('📅 Event ID: $eventId');
      
      _user = await _authService.addSponsoredEvent(
        userId: _user!.userId,
        eventId: eventId,
      );
      
      debugPrint('✅ AuthProvider: Sponsored event added successfully');
      debugPrint('📋 Total sponsored events: ${_user!.sponsoredEvents.length}');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Adding sponsored event failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPGRADE SPONSOR TIER METHOD
  Future<bool> upgradeSponsorTier(String newTier) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null || !_user!.isSponsor) {
        throw AuthException('Only sponsor users can upgrade tiers');
      }

      debugPrint('⬆️ AuthProvider: Upgrading sponsor tier for: ${_user!.organizationName}');
      debugPrint('🎯 Current tier: ${_user!.sponsorTier}, New tier: $newTier');
      
      _user = await _authService.upgradeSponsorTier(
        userId: _user!.userId,
        newTier: newTier,
      );
      
      debugPrint('✅ AuthProvider: Sponsor tier upgraded successfully');
      debugPrint('🏆 New tier: ${_user!.sponsorTier}');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Sponsor tier upgrade failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ACTIVATE/DEACTIVATE SPONSOR (ADMIN ONLY)
  Future<bool> manageSponsorStatus(String sponsorId, bool activate, {String? reason}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null || !_user!.isAdmin) {
        throw AuthException('Only admin users can manage sponsor status');
      }

      debugPrint('🛠️ AuthProvider: Managing sponsor status for: $sponsorId');
      debugPrint('📊 Action: ${activate ? 'Activate' : 'Deactivate'}');
      
      await _authService.manageSponsorStatus(
        sponsorId: sponsorId,
        activate: activate,
        reason: reason,
        adminId: _user!.userId,
      );
      
      debugPrint('✅ AuthProvider: Sponsor status updated successfully');
      
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Sponsor status management failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GET ALL SPONSORS (ADMIN ONLY)
  Future<List<UserModel>> getAllSponsors() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null || !_user!.isAdmin) {
        throw AuthException('Only admin users can access all sponsors');
      }

      debugPrint('📋 AuthProvider: Fetching all sponsors');
      
      final sponsors = await _authService.getAllSponsors();
      
      debugPrint('✅ AuthProvider: Retrieved ${sponsors.length} sponsors');
      
      return sponsors;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Failed to fetch sponsors: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GET SPONSORS BY TIER
  Future<List<UserModel>> getSponsorsByTier(String tier) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🏷️ AuthProvider: Fetching sponsors by tier: $tier');
      
      final sponsors = await _authService.getSponsorsByTier(tier);
      
      debugPrint('✅ AuthProvider: Retrieved ${sponsors.length} $tier sponsors');
      
      return sponsors;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Failed to fetch sponsors by tier: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GET ACTIVE SPONSORS
  Future<List<UserModel>> getActiveSponsors() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('📊 AuthProvider: Fetching active sponsors');
      
      final sponsors = await _authService.getActiveSponsors();
      
      debugPrint('✅ AuthProvider: Retrieved ${sponsors.length} active sponsors');
      
      return sponsors;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ AuthProvider: Failed to fetch active sponsors: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // EXISTING METHODS (Updated with sponsor support)
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Attempting Google sign in');
      
      _user = await _authService.signInWithGoogle();
      
      debugPrint('AuthProvider: Google sign in successful: ${_user?.name}');
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      _user = null;
      debugPrint('AuthProvider: Google sign in failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Attempting logout');
      
      await _authService.signOut();
      _user = null;
      
      debugPrint('AuthProvider: Logout successful');
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Logout failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Attempting password reset for: $email');
      
      await _authService.resetPassword(email);
      
      debugPrint('AuthProvider: Password reset email sent');
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Password reset failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Updating user profile');
      
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Refresh user data after update
      if (_user != null && _authService.currentUser != null) {
        _user = await _authService.getUser(_authService.currentUser!.uid);
        debugPrint('AuthProvider: Profile updated successfully: ${_user?.name}');
      }
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Profile update failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmail(String newEmail) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Updating email to: $newEmail');
      
      await _authService.updateEmail(newEmail);

      // Refresh user data after update
      if (_user != null && _authService.currentUser != null) {
        _user = await _authService.getUser(_authService.currentUser!.uid);
        debugPrint('AuthProvider: Email updated successfully');
      }
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Email update failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Updating password');
      
      await _authService.updatePassword(newPassword);
      
      debugPrint('AuthProvider: Password updated successfully');
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Password update failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Deleting account');
      
      await _authService.deleteAccount();
      _user = null;
      
      debugPrint('AuthProvider: Account deleted successfully');
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Account deletion failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('AuthProvider: Sending email verification');
      
      await _authService.sendEmailVerification();
      
      debugPrint('AuthProvider: Email verification sent');
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Failed to send email verification: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reloadUser() async {
    try {
      debugPrint('AuthProvider: Reloading user data');
      
      await _authService.reloadUser();
      if (_authService.currentUser != null) {
        _user = await _authService.getUser(_authService.currentUser!.uid);
        debugPrint('AuthProvider: User data reloaded: ${_user?.name}');
      }
      notifyListeners();
      return true;
      
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('AuthProvider: Failed to reload user: $e');
      return false;
    }
  }

  // Getters that proxy to AuthService
  bool get isLoggedIn => _authService.isLoggedIn;
  String? get userId => _authService.userId;
  String? get userEmail => _authService.userEmail;
  String? get userDisplayName => _authService.userDisplayName;
  String? get userPhotoURL => _authService.userPhotoURL;
  bool get isEmailVerified => _authService.isEmailVerified;
  String get authProvider => _authService.authProvider;
  bool get isGoogleUser => _authService.isGoogleUser;
  bool get isEmailUser => _authService.isEmailUser;

  // ROLE-BASED GETTERS (Updated with sponsor)
  bool get isAdmin => _user?.role == 'admin';
  bool get isNGO => _user?.role == 'ngo';
  bool get isCitizen => _user?.role == 'citizen';
  bool get isSponsor => _user?.role == 'sponsor';
  bool get isActiveSponsor => _user?.isActiveSponsor == true;

  // Sponsor-specific getters
  String? get organizationName => _user?.organizationName;
  String? get sponsorTier => _user?.sponsorTier;
  double get totalContribution => _user?.totalContribution ?? 0.0;
  List<String> get sponsoredEvents => _user?.sponsoredEvents ?? [];
  bool get canSponsorEvents => isSponsor && isActiveSponsor;

  // Get user role for display
  String get userRoleDisplay {
    if (isSponsor && organizationName != null) {
      return '$organizationName ($sponsorTierDisplay)';
    }
    switch (_user?.role) {
      case 'admin':
        return 'Administrator';
      case 'ngo':
        return 'NGO Member';
      case 'sponsor':
        return 'Sponsor';
      case 'citizen':
        return 'Citizen';
      default:
        return 'User';
    }
  }

  String get sponsorTierDisplay {
    switch (_user?.sponsorTier) {
      case 'platinum':
        return 'Platinum Sponsor';
      case 'gold':
        return 'Gold Sponsor';
      case 'silver':
        return 'Silver Sponsor';
      case 'bronze':
        return 'Bronze Sponsor';
      default:
        return 'Sponsor';
    }
  }

  // PERMISSION METHODS (Updated with sponsor permissions)
  bool canCreateEvents() => isAdmin || isNGO;
  bool canModerateContent() => isAdmin || isNGO;
  bool canManageUsers() => isAdmin;
  bool canAccessAdminDashboard() => isAdmin;
  bool canViewAnalytics() => isAdmin || isNGO;
  bool canExportData() => isAdmin || isNGO;
  bool canManageSponsors() => isAdmin;
  bool canVerifyNGOs() => isAdmin;

  // Check if user has specific role
  bool hasRole(String role) {
    return _user?.role == role;
  }

  // Validate if user can perform certain actions based on role
  bool canAccessFeature(String feature) {
    switch (feature) {
      case 'admin_dashboard':
        return isAdmin;
      case 'event_creation':
        return canCreateEvents();
      case 'content_moderation':
        return canModerateContent();
      case 'user_management':
        return canManageUsers();
      case 'analytics':
        return canViewAnalytics();
      case 'data_export':
        return canExportData();
      case 'system_settings':
        return canManageUsers();
      case 'ngo_verification':
        return canVerifyNGOs();
      case 'sponsor_dashboard':
        return isSponsor;
      case 'sponsor_events':
        return canSponsorEvents;
      case 'sponsor_management':
        return canManageSponsors();
      default:
        return true;
    }
  }

  // Check if user needs to complete profile
  bool get needsProfileCompletion {
    if (isSponsor) {
      return _user?.organizationName?.isEmpty ?? true;
    }
    return _user?.name.isEmpty ?? true;
  }

  // Check if current user is valid and ready
  bool get isUserValid {
    return _user != null && 
           _user!.userId.isNotEmpty && 
           _user!.name.isNotEmpty && 
           _user!.email.isNotEmpty;
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please use a different email or try logging in.';
        case 'invalid-email':
          return 'The email address is not valid. Please check and try again.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'user-not-found':
          return 'No account found with this email. Please check your email or sign up.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This operation is not allowed. Please contact support.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email but different sign-in method.';
        default:
          return e.message ?? 'An error occurred. Please try again.';
      }
    } else if (e is AuthException) {
      return e.message;
    } else {
      return e.toString();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user data from server
  Future<void> refreshUserData() async {
    if (_authService.currentUser != null) {
      try {
        _user = await _authService.getUser(_authService.currentUser!.uid);
        notifyListeners();
      } catch (e) {
        debugPrint('AuthProvider: Error refreshing user data: $e');
      }
    }
  }

  // Force notify listeners (useful for manual state updates)
  void forceNotify() {
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('AuthProvider: Disposing provider');
    super.dispose();
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