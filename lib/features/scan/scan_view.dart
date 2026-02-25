import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../home/add_beer/add_beer_view.dart';
import '../home/add_beer/add_beer_view_model.dart';
import '../beer/beer_detail/beer_detail_view.dart';
import '../beer/beer_model.dart';

import '../../core/utils/excluded_keywords.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  bool _isScanning = true;
  bool _isLoading = false;
  final MobileScannerController _cameraController = MobileScannerController();

  Future<void> _handleBarcode(String barcode) async {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    try {
      final apiClient = context.read<ApiClient>();

      final Map<String, dynamic>? beerData = await apiClient.getBeerByProductId(
        barcode,
      );

      if (beerData != null) {
        final beer = Beer.fromJson(beerData);
        _navigateToDetails(beer);
        return;
      }

      final product = await _fetchFromOpenFoodFacts(barcode);

      if (product != null) {
        final List<dynamic> keywords = product['_keywords'] ?? [];
        bool isExcluded = keywords.any(
          (k) => excludedKeywords.contains(k.toString().toLowerCase()),
        );

        if (isExcluded) {
          _showError("Ce produit n'est pas identifié comme une bière.");
          return;
        }

        _redirectToFillForm(barcode: product['_id'].toString(), data: product);
      } else {
        _showNotFoundDialog(barcode);
      }
    } catch (e) {
      debugPrint("Scan Error: $e");
      _showError("Une erreur est survenue lors du scan.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDetails(Beer beer) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BeerDetailView(
          beer: beer,
          isFromCollection: false,
          isFromScan: true,
        ),
      ),
    );
  }

  void _redirectToFillForm({
    required String barcode,
    Map<String, dynamic>? data,
  }) {
    final addVM = Provider.of<AddBeerViewModel>(context, listen: false);
    addVM.preFill(barcode, offData: data);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AddBeerView()),
    );
  }

  // API OpenFoodFacts
  Future<Map<String, dynamic>?> _fetchFromOpenFoodFacts(String barcode) async {
    final fields =
        "_id,brands,product_name_fr,image_url,product_quantity,abv,_keywords";
    final url = Uri.parse(
      "https://world.openfoodfacts.org/api/v0/product/$barcode.json?fields=$fields",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MyBeerApp - Flutter - v1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          return data['product'];
        }
      }
    } catch (e) {
      debugPrint("OFF Error: $e");
    }
    return null;
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Bière inconnue"),
        content: Text("Le code $barcode n'existe pas. Voulez-vous l'ajouter ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isScanning = true);
            },
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _redirectToFillForm(barcode: barcode);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isScanning = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Retour"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && _isScanning) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _handleBarcode(code);
                }
              }
            },
          ),

          _buildOverlay(),

          if (_isLoading)
            Container(
              color: const Color.fromARGB(129, 0, 0, 0).withValues(),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber, width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Placez le code-barres dans le cadre",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
