import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/business.dart';

class ApiClient {
  Uri get _base => Uri.parse(AppConstants.apiBaseUrl);

  Future<Business> fetchBusiness(String slug) async {
    final res = await http.get(_base.resolve('/api/businesses/$slug'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load business (${res.statusCode})');
    }
    return Business.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<dynamic>> fetchFeedbacks() async {
    final res = await http.get(_base.resolve('/api/feedbacks'));
    if (res.statusCode != 200) throw Exception('Failed to load feedbacks');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<void> sendFeedback({
    required String name,
    required int rating,
    required String comment,
  }) async {
    final res = await http.post(
      _base.resolve('/api/feedbacks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'rating': rating, 'comment': comment}),
    );
    if (res.statusCode >= 300) throw Exception('Failed to send feedback');
  }

  Future<void> sendEnquiry({
    required String name,
    required String phone,
    String? email,
    required String message,
  }) async {
    final res = await http.post(
      _base.resolve('/api/enquiries'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {'name': name, 'phone': phone, 'email': email, 'message': message},
      ),
    );
    if (res.statusCode >= 300) throw Exception('Failed to send enquiry');
  }

  Future<int> fetchViews(String slug) async {
    final res = await http.get(_base.resolve('/api/businesses/$slug/views'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load views');
    }
    return (jsonDecode(res.body) as Map<String, dynamic>)['views'] as int;
  }

  Future<int> incrementViews(String slug) async {
    final res = await http.post(_base.resolve('/api/businesses/$slug/views/increment'));
    if (res.statusCode != 200) {
      throw Exception('Failed to increment views');
    }
    return (jsonDecode(res.body) as Map<String, dynamic>)['views'] as int;
  }
}