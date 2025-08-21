import 'package:flutter/foundation.dart';
import '../models/business.dart';
import '../services/api_client.dart';
import '../constants.dart';

class BusinessProvider extends ChangeNotifier {
  final _api = ApiClient();
  Business? business;
  bool loading = false;
  String? error;

  int? views; // NEW
  bool _incremented = false; // NEW: ensure +1 per load

  Future<void> loadForCurrentUrl() async {
    final uri = Uri.base; // works on Flutter Web
    final slug = uri.queryParameters['biz'] ?? 'business slug';
    await load(slug);
  }

  Future<void> load(String slug) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      business = await _api.fetchBusiness(slug);
      // Increment views only once per app session
      if (!_incremented) {
        views = await _api.incrementViews(slug);
        _incremented = true;
      } else {
        views = await _api.fetchViews(slug);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
