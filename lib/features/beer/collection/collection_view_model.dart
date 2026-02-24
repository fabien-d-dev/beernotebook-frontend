import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import 'collection_model.dart';

enum BeerSortType { rating, brewery, date }

class CollectionViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final int userId;
  final int collectionId;

  CollectionViewModel(this._apiClient, this.userId, this.collectionId);

  List<CollectionItem> _userCollection = [];
  List<CollectionItem> get userCollection => _userCollection;
  bool isLoading = false;
  BeerSortType _currentSortType = BeerSortType.rating;
  BeerSortType get currentSortType => _currentSortType;

  void toggleSort() {
    if (_currentSortType == BeerSortType.rating) {
      _currentSortType = BeerSortType.brewery;
    } else if (_currentSortType == BeerSortType.brewery) {
      _currentSortType = BeerSortType.date;
    } else {
      _currentSortType = BeerSortType.rating;
    }
    notifyListeners();
  }

  List<CollectionItem> get sortedCollection {
    List<CollectionItem> sortedList = List.from(_userCollection);

    switch (_currentSortType) {
      case BeerSortType.rating:
        // Sort by rating (descending)
        sortedList.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case BeerSortType.brewery:
        // Sorted by brewery (alphabetical)
        sortedList.sort(
          (a, b) =>
              a.beer.brand.toLowerCase().compareTo(b.beer.brand.toLowerCase()),
        );
        break;
      case BeerSortType.date:
        sortedList.sort((a, b) {
          // Sort by creation date (from newest to oldest)
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }
    return sortedList;
  }

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

  Future<void> updateRating(int beerId, double rating) async {
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

  Future<void> updateTasting(int beerId, Map<String, dynamic> data) async {
    try {
      await _apiClient.saveBeerTasting(collectionId, beerId, data);

      final index = _userCollection.indexWhere(
        (item) => item.beer.id == beerId,
      );
      if (index != -1) {
        final oldItem = _userCollection[index];

        _userCollection[index] = CollectionItem(
          beer: oldItem.beer,
          rating: oldItem.rating,
          createdAt: data['createdAt'],
          beerColor: data['beerColor'] ?? oldItem.beerColor,
          clarity: data['clarity'] ?? oldItem.clarity,
          bitterness: data['bitterness'] ?? oldItem.bitterness,
          observations: data['observations'] ?? oldItem.observations,
          headColor: data['headColor'],
          headRetention: data['headRetention'],
          carbonation: data['carbonation'],
        );

        _userCollection = List.from(_userCollection);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour de la dégustation: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchBeerTasting(int beerId) async {
    try {
      final data = await _apiClient.getBeerTasting(collectionId, beerId);

      if (data != null) {
        final index = _userCollection.indexWhere(
          (item) => item.beer.id == beerId,
        );
        if (index != -1) {
          final oldItem = _userCollection[index];
          _userCollection[index] = CollectionItem(
            beer: oldItem.beer,
            rating: oldItem.rating,
            createdAt: oldItem.createdAt,
            beerColor: data['beerColor'],
            clarity: data['clarity'],
            bitterness: data['bitterness'],
            observations: data['observations'],
            headColor: data['headColor'] ?? oldItem.headColor,
            headRetention: data['headRetention'] ?? oldItem.headRetention,
            carbonation: data['carbonation'] ?? oldItem.carbonation,
          );
        }
      }
      return data;
    } catch (e) {
      debugPrint("Erreur lors du fetch tasting: $e");
      return null;
    }
  }

  Future<void> addToCollection(int beerId) async {
    try {
      await _apiClient.addBeerToCollection(collectionId, beerId);

      await loadUserCollection();
    } catch (e) {
      debugPrint("Erreur lors de l'ajout : $e");
      rethrow;
    }
  }

  bool isBeerInCollection(int beerId) {
    return _userCollection.any((item) => item.beer.id == beerId);
  }

  Future<void> removeFromCollection(int beerId) async {
    try {
      await _apiClient.removeBeerFromCollection(collectionId, beerId);

      await loadUserCollection();
    } catch (e) {
      debugPrint("Erreur lors de la suppression : $e");
      rethrow;
    }
  }
}
