import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/appwrite_config.dart';
import '../../../core/config/environment.dart';
import '../../beer/beer_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddBeerViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final AppwriteConfig _appwriteConfig = AppwriteConfig();
  final int userId;

  AddBeerViewModel({required this.userId});

  Beer? _createdBeer;
  Beer? get createdBeer => _createdBeer;

  // States
  bool _showExtraFields = false;
  bool get showExtraFields => _showExtraFields;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _selectedOrigin;
  String? get selectedOrigin => _selectedOrigin;

  String? _selectedType;
  String? get selectedType => _selectedType;

  // Controllers
  final barcodeController = TextEditingController();
  final breweryController = TextEditingController();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final abvController = TextEditingController();
  final hopsController = TextEditingController();
  final ingredientsController = TextEditingController();
  final allergensController = TextEditingController();

  File? _imageFile;
  File? get imageFile => _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Actions
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

  // Internal method to upload image to Appwrite and get the public URL
  Future<String?> _uploadImageToAppwrite() async {
    if (_imageFile == null) return null;

    try {
      final String fileName =
          'beer_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await _appwriteConfig.storage.createFile(
        bucketId: Env.appwriteBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: _imageFile!.path, filename: fileName),
      );

      return _appwriteConfig.getFileViewUrl(result.$id);
    } catch (e) {
      debugPrint("❌ Appwrite Upload Error: $e");
      return null;
    }
  }

  Future<bool> submitBeer() async {
    if (_isLoading) return false;

    _createdBeer = null;

    final String productId = barcodeController.text.trim();
    final String brand = breweryController.text.trim();
    final String name = nameController.text.trim();

    if (productId.isEmpty || productId.length < 13) {
      debugPrint("Validation failed: product_id too short");
      return false;
    }

    if (brand.isEmpty || name.isEmpty) {
      debugPrint("Validation failed: Missing required fields");
      return false;
    }

    _setLoading(true);

    try {
      // Handle image upload to Appwrite first
      String? finalImageUrl;
      if (_imageFile != null) {
        finalImageUrl = await _uploadImageToAppwrite();
      }

      final int? quantity = int.tryParse(quantityController.text.trim());
      final double? abv = double.tryParse(
        abvController.text.trim().replaceAll(',', '.'),
      );

      final beerData = {
        'brand': breweryController.text.trim(),
        'product_id': productId,
        'generic_name': nameController.text.trim(),
        'quantity': quantity,
        'abv': abv,
        'type': _selectedType,
        'manufacturing_place': _selectedOrigin,
        'image_url': finalImageUrl,
        'user_id': userId,
        'hops': hopsController.text.trim(),
        'ingredients': ingredientsController.text.trim(),
        'allergens': allergensController.text.trim(),
      };

      // Call API to create the beer in the database
      final result = await _apiClient.createBeer(beerData);

      // Convert the API response into a Beer object.
      if (result.containsKey('beer')) {
        _createdBeer = Beer.fromJson(result['beer']);
        _setLoading(false);
        return true;
      } else if (result.containsKey('id')) {
        _createdBeer = Beer.fromJson(result);
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint("Error in submitBeer: $e");
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

  Future<void> takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
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

  void resetPhoto() {
    _imageFile = null;
    notifyListeners();
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

  void reset() {
    _createdBeer = null;
    notifyListeners();
  }
}
