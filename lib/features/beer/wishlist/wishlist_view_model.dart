import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import 'wishlist_model.dart';

class WishlistViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final int wishlistId;

  WishlistViewModel(this._apiClient, this.wishlistId);

  List<WishlistItem> _wishlistBeers = [];
  List<WishlistItem> get wishlistBeers => _wishlistBeers;
  bool isLoading = false;

  Future<void> loadWishlist() async {
    isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawData = await _apiClient.getWishlistBeers(
        wishlistId,
      );
      _wishlistBeers = rawData
          .map((json) => WishlistItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint("Error Wishlist: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWishlist(int beerId) async {
    try {
      await _apiClient.addBeerToWishlist(wishlistId, beerId);

      await loadWishlist();
    } catch (e) {
      debugPrint("Erreur lors de l'ajout : $e");
      rethrow;
    }
  }

  bool isBeerInWishlist(int beerId) {
    return _wishlistBeers.any((item) => item.beer.id == beerId);
  }

  Future<void> removeFromWishlist(int beerId) async {
    try {
      await _apiClient.removeBeerFromWishlist(wishlistId, beerId);

      await loadWishlist();
    } catch (e) {
      debugPrint("Erreur lors de la suppression : $e");
      rethrow;
    }
  }
}
