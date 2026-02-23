import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import 'beer_model.dart';

class BeerViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  BeerViewModel(this._apiClient);

  List<Beer> _catalogBeers = [];
  List<Beer> get catalogBeers => _catalogBeers;

  int _catalogPage = 1;
  bool hasMoreCatalog = true;
  bool isLoading = false;

  String? _barcodeBase64;
  String? get barcodeBase64 => _barcodeBase64;

  bool _isGeneratingBarcode = false;
  bool get isGeneratingBarcode => _isGeneratingBarcode;

  Future<void> loadCatalog({bool isRefresh = false}) async {
    if (isLoading || (!isRefresh && !hasMoreCatalog)) return;
    if (isRefresh) _catalogPage = 1;

    isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawData = await _apiClient.getBeers(
        page: _catalogPage,
      );
      final fetched = rawData.map((json) => Beer.fromJson(json)).toList();

      if (isRefresh) {
        _catalogBeers = fetched;
      } else {
        final existingIds = _catalogBeers.map((b) => b.id).toSet();
        _catalogBeers.addAll(fetched.where((b) => !existingIds.contains(b.id)));
      }

      hasMoreCatalog = fetched.length >= 20;
      if (hasMoreCatalog) _catalogPage++;
    } catch (e) {
      debugPrint("Error Catalog: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBarcode(String productId) async {
    _isGeneratingBarcode = true;
    _barcodeBase64 = null;
    notifyListeners();

    try {
      final String result = await _apiClient.getBarcodeImage(productId);

      _barcodeBase64 = result;
    } catch (e) {
      debugPrint("Error generating barcode: $e");
    } finally {
      _isGeneratingBarcode = false;
      notifyListeners();
    }
  }
}
