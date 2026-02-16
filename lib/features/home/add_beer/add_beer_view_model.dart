import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class AddBeerViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final int userId;

  AddBeerViewModel({required this.userId});

  bool _showExtraFields = false;
  bool get showExtraFields => _showExtraFields;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _selectedOrigin;
  String? get selectedOrigin => _selectedOrigin;

  String? _selectedType;
  String? get selectedType => _selectedType;

  final barcodeController = TextEditingController();
  final breweryController = TextEditingController();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final abvController = TextEditingController();
  final hopsController = TextEditingController();
  final ingredientsController = TextEditingController();
  final allergensController = TextEditingController();

  void toggleExtraFields() {
    _showExtraFields = !_showExtraFields;
    notifyListeners();
  }

  void setOrigin(String? value) {
    _selectedOrigin = value;
    notifyListeners();
  }

  void setType(String? value) {
    _selectedType = value;
    notifyListeners();
  }

  Future<bool> submitBeer() async {
    if (_isLoading) return false;
    _setLoading(true);

    try {
      final beerData = {
        'brand': breweryController.text.trim(),
        'product_id': barcodeController.text.trim(),
        'generic_name': nameController.text.trim(),
        'quantity': quantityController.text.trim(),
        'abv': abvController.text.trim(),
        'type': _selectedType,
        'manufacturing_place': _selectedOrigin,
        'image_url': null,
        'user_id': userId,
        'hops': hopsController.text.trim(),
        'ingredients': ingredientsController.text.trim(),
        'allergens': allergensController.text.trim(),
      };

      final result = await _apiClient.createBeer(beerData);

      if (result.containsKey('message')) {
        _setLoading(false);
        return true;
      }
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint("Error in ViewModel submitBeer: $e");
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    barcodeController.dispose();
    breweryController.dispose();
    nameController.dispose();
    quantityController.dispose();
    abvController.dispose();
    hopsController.dispose();
    ingredientsController.dispose();
    allergensController.dispose();
    super.dispose();
  }
}
