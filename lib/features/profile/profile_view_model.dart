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

  bool get isLoading => _isLoading;

  String get username =>
      _userData?['username'] ?? _userData?['user_name'] ?? "User";
  String get email => _userData?['email'] ?? "...";

  int get collectionCount => _collectionBeers.length;
  int get wishlistCount => _wishlistBeers.length;

  // Subscription helpers
  bool get isStandardAccount => _userData?['subscription_type'] == 'standard';
  String get subscriptionType =>
      _userData?['subscription']?['subscription_type'] ?? "Standard";

  // Mocked dates for now, should ideally come from _userData
  // TODO: DATA
  String get startDate => "26/11/2024";
  String get renewalDate => "26/02/2026";
  bool get isAutoRenewal => true;

  ProfileViewModel(
    this._apiClient, {
    required this.userId,
    required this.collectionId,
    required this.wishlistId,
  }) {
    // Automatically fetch data when ViewModel is created
    refreshData();
  }

  Future<void> refreshData() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Basic Profile Info
      _userData = await _apiClient.getUserProfile(userId);
      // debugPrint("DEBUG: User Data loaded: $_userData");

      // Fetch Collection (Handling the 404 if empty)
      try {
        _collectionBeers = await _apiClient.getUserBeers(userId);
      } catch (e) {
        // If API returns 404, it means the collection is just empty
        debugPrint("DEBUG: Collection is empty or unreachable");
        _collectionBeers = [];
      }

      // Fetch Wishlist (Handling the 404 if empty)
      try {
        _wishlistBeers = await _apiClient.getWishlistBeers(wishlistId);
      } catch (e) {
        debugPrint("DEBUG: Wishlist is empty or unreachable");
        _wishlistBeers = [];
      }
    } catch (e) {
      debugPrint("DEBUG ERROR: Global fetch failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
