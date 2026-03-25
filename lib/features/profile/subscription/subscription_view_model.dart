import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class SubscriptionViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  SubscriptionViewModel(this._apiClient);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> getPaymentUrl(int userId) async {
    _setLoading(true);
    try {
      final String paymentUrl = await _apiClient.createPaymentUrl(userId);
      return paymentUrl;
    } catch (e) {
      debugPrint("SubscriptionViewModel Error (getPaymentUrl): $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelSubscription(int userId) async {
    _setLoading(true);
    try {
      await _apiClient.cancelSubscription(userId);
      return true;
    } catch (e) {
      debugPrint("SubscriptionViewModel Error (cancelSubscription): $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
