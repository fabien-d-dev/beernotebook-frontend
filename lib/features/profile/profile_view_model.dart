import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final int userId;
  final int collectionId;
  final int wishlistId;

  Map<String, dynamic>? _userData;
  List<dynamic> _collectionBeers = [];
  List<dynamic> _wishlistBeers = [];
  bool _isLoading = false;
  bool _isDisposed = false; // To prevent memory leak errors

  bool get isLoading => _isLoading;

  // USER INFO
  String get username =>
      _userData?['username'] ?? _userData?['user_name'] ?? "Utilisateur";
  String get email => _userData?['email'] ?? "...";

  // COUNTERS
  int get collectionCount => _collectionBeers.length;
  int get wishlistCount => _wishlistBeers.length;

  // SUBSCRIPTION LOGIC
  bool get isStandardAccount =>
      _userData?['subscription']?['subscription_type'] == 'standard' ||
      _userData?['subscription'] == null;

  String get subscriptionType =>
      _userData?['subscription']?['subscription_type'] ?? "Standard";

  // DYNAMIC DATES
  String get startDate =>
      _formatDate(_userData?['created_date']) ?? "Date inconnue";

  String get renewalDate {
    final sub = _userData?['subscription'];
    final date = sub?['next_billing_date'] ?? sub?['expires_at'];
    return _formatDate(date) ?? "--/--/----";
  }

  bool get isAutoRenewal =>
      _userData?['subscription']?['is_auto_renew'] == true ||
      _userData?['subscription']?['is_auto_renew'] == 1;

  ProfileViewModel(
    this._apiClient, {
    required this.userId,
    required this.collectionId,
    required this.wishlistId,
  }) {
    refreshData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // REFRESH DATA
  Future<void> refreshData() async {
    if (_isLoading) return;
    _isLoading = true;
    _safeNotify();

    try {
      // 1. Fetch User Profile
      _userData = await _apiClient.getUserProfile(userId);

      // 2. Fetch Collection
      try {
        _collectionBeers = await _apiClient.getUserBeers(userId);
      } catch (e) {
        debugPrint("DEBUG: Collection empty for profile");
        _collectionBeers = [];
      }

      // 3. Fetch Wishlist
      try {
        _wishlistBeers = await _apiClient.getWishlistBeers(wishlistId);
      } catch (e) {
        debugPrint("DEBUG: Wishlist empty for profile");
        _wishlistBeers = [];
      }
    } catch (e) {
      debugPrint("DEBUG ERROR: Profile refresh failed: $e");
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  // HELPER: Format date from ISO to DD/MM/YYYY
  String? _formatDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  // SECURITY: Only notify if the view model still exists
  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
