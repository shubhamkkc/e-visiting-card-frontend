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
    final uri = Uri.base;
    print("base url:${uri}"); // works on Flutter Web
    final raw = uri.queryParameters['biz'];
    // Normalize slug: trim, lower, spaces->hyphens; fallback to default constant
    String normalized = (raw == null || raw.trim().isEmpty)
        ? AppConstants.defaultBusinessSlug
        : raw.trim().toLowerCase().replaceAll(RegExp(r"\s+"), '-');
    print("slug param raw: $raw  => normalized: $normalized");
    await load(normalized);
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
