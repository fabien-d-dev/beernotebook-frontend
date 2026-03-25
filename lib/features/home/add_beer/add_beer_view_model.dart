import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/appwrite_config.dart';
import '../../../core/config/environment.dart';
import '../../beer/beer_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/beer_data.dart';

class AddBeerViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final AppwriteConfig _appwriteConfig = AppwriteConfig();
  final int userId;

  AddBeerViewModel({required this.userId});

  Beer? _createdBeer;
  Beer? get createdBeer => _createdBeer;

  bool _showExtraFields = false;
  bool get showExtraFields => _showExtraFields;

  bool _isBarcodePreFilled = false;
  bool get isBarcodePreFilled => _isBarcodePreFilled;

  int? _existingBeerId;
  int? get existingBeerId => _existingBeerId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _selectedOrigin;
  String? get selectedOrigin => _selectedOrigin;

  String? _selectedType;
  String? get selectedType => _selectedType;

  File? _imageFile;
  File? get imageFile => _imageFile;

  String? _existingImageUrl;
  String? get existingImageUrl => _existingImageUrl;

  final ImagePicker _picker = ImagePicker();

  final barcodeController = TextEditingController();
  final breweryController = TextEditingController();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final abvController = TextEditingController();
  final hopsController = TextEditingController();
  final ingredientsController = TextEditingController();
  final allergensController = TextEditingController();

  Future<bool> submitBeer() async {
    if (_isLoading) return false;
    if (!_validateFields()) return false;

    _createdBeer = null;
    _setLoading(true);

    try {
      final beerData = await _buildBeerData();
      final result = await _apiClient.createBeer(beerData);

      int? newId;
      if (result['beer'] != null && result['beer']['insertId'] != null) {
        newId = result['beer']['insertId'];
      }

      if (newId != null) {
        _createdBeer = _buildBeerFromCurrentInput(
          newId,
          uploadedImageUrl: beerData['image_url'],
        );
      } else {
        _createdBeer = _parseBeerResponse(result);
      }

      _setLoading(false);
      notifyListeners();
      return _createdBeer != null;
    } catch (e) {
      _setLoading(false);
      debugPrint("Error in submitBeer: $e");
      return false;
    }
  }

  Beer _buildBeerFromCurrentInput(int id, {String? uploadedImageUrl}) {
    final int? inputQuantityCentiliters = int.tryParse(
      quantityController.text.trim(),
    );
    final String databaseQuantityMilliliters = inputQuantityCentiliters != null
        ? (inputQuantityCentiliters * 10).toString()
        : "";

    return Beer(
      id: id,
      brand: breweryController.text.trim(),
      productId: barcodeController.text.trim(),
      genericName: nameController.text.trim(),
      quantity: databaseQuantityMilliliters,
      abv: abvController.text.trim(),
      type: _selectedType,
      manufacturingPlace: _selectedOrigin,
      hops: hopsController.text.trim(),
      ingredients: ingredientsController.text.trim(),
      allergens: allergensController.text.trim(),
      imageUrl: uploadedImageUrl ?? _existingImageUrl,
    );
  }

  Future<bool> updateBeer() async {
    if (_isLoading) return false;
    if (_existingBeerId == null) return false;
    if (!_validateFields()) return false;

    _createdBeer = null;
    _setLoading(true);

    try {
      final beerData = await _buildBeerData();

      final result = await _apiClient.updateBeer(_existingBeerId!, beerData);

      _createdBeer = _parseBeerResponse(result);

      _createdBeer ??= _buildBeerFromCurrentInput(
        _existingBeerId!,
        uploadedImageUrl: beerData['image_url'],
      );

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint("Error in updateBeer: $e");
      return false;
    }
  }

  bool _validateFields() {
    final productId = barcodeController.text.trim();
    final brand = breweryController.text.trim();
    final name = nameController.text.trim();

    if (productId.isEmpty || productId.length < 13) {
      debugPrint("Validation failed: product_id too short");
      return false;
    }

    if (brand.isEmpty || name.isEmpty) {
      debugPrint("Validation failed: Missing required fields");
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>> _buildBeerData() async {
    String? finalImageUrl;

    if (_imageFile != null) {
      finalImageUrl = await _uploadImageToAppwrite();
    }

    final String rawQuantity = quantityController.text.trim();
    int? finalQuantity;

    if (rawQuantity.isNotEmpty) {
      final int? inputQuantity = int.tryParse(rawQuantity);
      if (inputQuantity != null) {
        finalQuantity = inputQuantity * 10; // Ex: 33 -> 330
      }
    }

    final double? abv = double.tryParse(
      abvController.text.trim().replaceAll(',', '.'),
    );

    final beerData = {
      'brand': breweryController.text.trim(),
      'product_id': barcodeController.text.trim(),
      'generic_name': nameController.text.trim(),
      'quantity': finalQuantity,
      'abv': abv,
      'type': _selectedType,
      'manufacturing_place': _selectedOrigin,
      'user_id': userId,
      'hops': hopsController.text.trim(),
      'ingredients': ingredientsController.text.trim(),
      'allergens': allergensController.text.trim(),
    };

    if (finalImageUrl != null) {
      beerData['image_url'] = finalImageUrl;
    } else if (_existingImageUrl != null) {
      beerData['image_url'] = _existingImageUrl;
    }

    return beerData;
  }

  Beer? _parseBeerResponse(Map<String, dynamic> result) {
    if (result.containsKey('beer')) {
      return Beer.fromJson(result['beer']);
    }

    if (result.containsKey('id') || result.containsKey('product_id')) {
      return Beer.fromJson(result);
    }

    return null;
  }

  Future<String?> _uploadImageToAppwrite() async {
    if (_imageFile == null) return null;

    try {
      final fileName = 'beer_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await _appwriteConfig.storage.createFile(
        bucketId: Env.appwriteBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: _imageFile!.path, filename: fileName),
      );

      return _appwriteConfig.getFileViewUrl(result.$id);
    } catch (e) {
      debugPrint("Appwrite Upload Error: $e");
      return null;
    }
  }

  void preFill(String barcode, {Map<String, dynamic>? offData}) {
    barcodeController.text = barcode;

    if (offData != null) {
      breweryController.text = offData['brands'] ?? "";
      nameController.text =
          offData['product_name_fr'] ?? offData['product_name'] ?? "";
      quantityController.text = offData['product_quantity']?.toString() ?? "";
      abvController.text = offData['abv']?.toString() ?? "";
    }

    notifyListeners();
  }

  void prefillWithBeer(Beer beer) {
    if (beer.productId != null && beer.productId!.isNotEmpty) {
      barcodeController.text = beer.productId!;
      _isBarcodePreFilled = true;
    } else {
      barcodeController.text = '';
      _isBarcodePreFilled = false;
    }

    breweryController.text = beer.brand;
    nameController.text = beer.genericName ?? '';

    if (beer.quantity != null && beer.quantity!.isNotEmpty) {
      final double? q = double.tryParse(beer.quantity!);
      if (q != null) {
        final double display = q / 10; // Ex: 330 -> 33.0
        // Remove .0 if it's a round number
        quantityController.text = display % 1 == 0
            ? display.toInt().toString()
            : display.toString();
      } else {
        quantityController.text = '';
      }
    } else {
      quantityController.text = '';
    }

    abvController.text = beer.abv?.toString() ?? '';

    if (beer.manufacturingPlace != null &&
        beer.manufacturingPlace!.isNotEmpty) {
      final exists = BeerData.beerManufacturingPlaces.any(
        (m) => m['value'] == beer.manufacturingPlace,
      );
      _selectedOrigin = exists ? beer.manufacturingPlace : null;
    } else {
      _selectedOrigin = null;
    }

    if (beer.type != null && beer.type!.isNotEmpty) {
      final exists = BeerData.beerTypes.any((m) => m['value'] == beer.type);
      _selectedType = exists ? beer.type : null;
    } else {
      _selectedType = null;
    }

    hopsController.text = beer.hops ?? '';
    ingredientsController.text = beer.ingredients ?? '';
    allergensController.text = beer.allergens ?? '';

    _showExtraFields =
        (beer.hops?.isNotEmpty ?? false) ||
        (beer.ingredients?.isNotEmpty ?? false) ||
        (beer.allergens?.isNotEmpty ?? false);

    _existingImageUrl = beer.imageUrl;
    _existingBeerId = beer.id;

    notifyListeners();
  }

  Future<void> takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearExistingImage() {
    _existingImageUrl = null;
    notifyListeners();
  }

  void resetPhoto() {
    _imageFile = null;
    notifyListeners();
  }

  void reset() {
    _createdBeer = null;
    _existingImageUrl = null;
    _existingBeerId = null;
    _isBarcodePreFilled = false;
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
