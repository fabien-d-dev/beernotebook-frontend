import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  String get title => "BeerNotebook";
  String get newsTitle => "Actu Bière & Brasseries";

  List<Map<String, dynamic>> _articles = [];
  List<Map<String, dynamic>> get articles => _articles;
  bool isLoading = false;

  Future<void> loadArticles() async {
    isLoading = true;
    notifyListeners();

    try {
      _articles = await _apiClient.getArticles();
    } catch (e) {
      debugPrint("Erreur lors du chargement des articles: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
