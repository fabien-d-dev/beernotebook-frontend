import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import 'collection_model.dart';

class CollectionViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final int userId;
  final int collectionId;

  CollectionViewModel(this._apiClient, this.userId, this.collectionId);

  List<CollectionItem> _userCollection = [];
  List<CollectionItem> get userCollection => _userCollection;
  bool isLoading = false;

  Future<void> loadUserCollection() async {
    isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawData = await _apiClient.getUserBeers(userId);
      _userCollection = rawData
          .map((json) => CollectionItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint("Error Collection: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTasting(int beerId, double rating) async {
    try {
      await _apiClient.updateBeerRating(collectionId, beerId, rating);

      final index = _userCollection.indexWhere(
        (item) => item.beer.id == beerId,
      );

      if (index != -1) {
        final oldItem = _userCollection[index];

        _userCollection[index] = CollectionItem(
          beer: oldItem.beer,
          rating: rating,
          createdAt: oldItem.createdAt,
          beerColor: oldItem.beerColor,
          headColor: oldItem.headColor,
          headRetention: oldItem.headRetention,
          clarity: oldItem.clarity,
          carbonation: oldItem.carbonation,
          bitterness: oldItem.bitterness,
          observations: oldItem.observations,
        );

        _userCollection = List.from(_userCollection);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur note: $e");
      rethrow;
    }
  }
}
