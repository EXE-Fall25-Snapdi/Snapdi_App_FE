import 'dart:convert';
import '../storage/token_storage.dart';
import '../../features/auth/data/models/user.dart';

/// Provider class for accessing user information from token storage
/// This class provides a centralized way to retrieve and parse user data
/// stored during login/signup across the application.
class UserInfoProvider {
  static final UserInfoProvider _instance = UserInfoProvider._internal();
  
  factory UserInfoProvider() => _instance;
  
  UserInfoProvider._internal();
  
  /// Get the singleton instance
  static UserInfoProvider get instance => _instance;
  
  final TokenStorage _tokenStorage = TokenStorage.instance;
  
  /// Cached user object to avoid repeated parsing
  User? _cachedUser;
  
  /// Get the full user object from storage
  /// Returns null if no user is logged in or parsing fails
  Future<User?> getUser() async {
    try {
      final userInfoJson = await _tokenStorage.getUserInfo();
      if (userInfoJson == null) return null;
      
      final Map<String, dynamic> data = jsonDecode(userInfoJson);
      _cachedUser = User.fromJson(data);
      return _cachedUser;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user name
  Future<String?> getUserName() async {
    try {
      final user = await getUser();
      return user?.name;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user email
  Future<String?> getUserEmail() async {
    try {
      final user = await getUser();
      return user?.email;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user phone
  Future<String?> getUserPhone() async {
    try {
      final user = await getUser();
      return user?.phone;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user ID
  Future<int?> getUserId() async {
    try {
      // First try from TokenStorage directly (faster)
      final userId = await _tokenStorage.getUserId();
      if (userId != null) return userId;
      
      // Fallback to parsing from user info
      final user = await getUser();
      return user?.userId;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user avatar URL
  Future<String?> getAvatarUrl() async {
    try {
      final user = await getUser();
      return user?.avatarUrl;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user location city
  Future<String?> getLocationCity() async {
    try {
      final user = await getUser();
      return user?.locationCity;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user location address
  Future<String?> getLocationAddress() async {
    try {
      final user = await getUser();
      return user?.locationAddress;
    } catch (e) {
      return null;
    }
  }
  
  /// Get user role name
  Future<String?> getRoleName() async {
    try {
      final user = await getUser();
      return user?.roleName;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if user is verified
  Future<bool> isVerified() async {
    try {
      final user = await getUser();
      return user?.isVerify ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if user is active
  Future<bool> isActive() async {
    try {
      final user = await getUser();
      return user?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Clear the cached user data
  /// Call this after logout or when user data is updated
  void clearCache() {
    _cachedUser = null;
  }
  
  /// Refresh user data from storage
  /// Useful after profile updates
  Future<User?> refresh() async {
    clearCache();
    return await getUser();
  }
}
