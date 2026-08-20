import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _baseUrl = 'http://127.0.0.1:8000/api';
  static String get baseUrl => _baseUrl;

  static String? _token;

  // ---------------------------------------------------------------------------
  // Server URL management
  // ---------------------------------------------------------------------------

  static String _normalizeUrl(String url) {
    var s = url.trimRight();
    if (s.endsWith('/')) s = s.substring(0, s.length - 1);
    final uri = Uri.tryParse(s);
    if (uri != null && uri.host.isNotEmpty) {
      final hasApiPath = uri.path == '/api' || uri.path.startsWith('/api/');
      if (uri.path.isEmpty) {
        s = '$s/api';
      } else if (!hasApiPath) {
        s = '${uri.scheme}://${uri.host}${uri.port != 0 ? ':${uri.port}' : ''}/api';
      }
    }
    return s;
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = _normalizeUrl(prefs.getString('server_url') ?? 'http://127.0.0.1:8000/api');
    await prefs.setString('server_url', _baseUrl);
  }

  static Future<void> setBaseUrl(String url) async {
    _baseUrl = _normalizeUrl(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _baseUrl);
  }

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
    return _token;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  // ---------------------------------------------------------------------------
  // HTTP helpers
  // ---------------------------------------------------------------------------

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _decode(http.Response res) {
    try {
      final body = json.decode(res.body);
      if (body is Map<String, dynamic>) return body;
      return {'data': body};
    } catch (_) {
      return {'error': res.body};
    }
  }

  static void _throwIfError(http.Response res) {
    if (res.statusCode >= 400) {
      final body = _decode(res);
      throw ApiException(
        body['message'] as String? ?? 'Request failed',
        res.statusCode,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// Login with email and password. Returns {user, token}.
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await _headers(),
      body: json.encode({'email': email, 'password': password}),
    );
    _throwIfError(res);
    final data = _decode(res);
    final token = (data['token'] ?? data['access_token']) as String?;
    if (token != null) await setToken(token);
    return data;
  }

  /// Register a new user. Returns {user, token}.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await _headers(),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      }),
    );
    _throwIfError(res);
    final data = _decode(res);
    await setToken(data['token'] as String);
    return data;
  }

  /// Logout the current user.
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _headers(auth: true),
      );
    } catch (_) {}
    await clearToken();
  }

  /// Get current user profile.
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    return _decode(res);
  }

  /// Update user profile.
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/user'),
      headers: await _headers(auth: true),
      body: json.encode(data),
    );
    _throwIfError(res);
    return _decode(res);
  }

  // ---------------------------------------------------------------------------
  // Foods
  // ---------------------------------------------------------------------------

  /// Get all food items. Optionally filter by search and category.
  static Future<List<dynamic>> getFoods({String? search, String? category}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category != 'All') params['category'] = category;

    final uri = Uri.parse('$baseUrl/foods').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    _throwIfError(res);
    final body = json.decode(res.body);
    return body is List ? body : (body['data'] as List? ?? []);
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  /// Get customer's order history.
  static Future<List<dynamic>> getOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    final body = json.decode(res.body);
    return body is List ? body : (body['data'] as List? ?? []);
  }

  /// Place a new order.
  static Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _headers(auth: true),
      body: json.encode(data),
    ).timeout(const Duration(seconds: 15));
    _throwIfError(res);
    return _decode(res);
  }

  // ---------------------------------------------------------------------------
  // Seller
  // ---------------------------------------------------------------------------

  /// Get seller's food items.
  static Future<List<dynamic>> getSellerFoods() async {
    final res = await http.get(
      Uri.parse('$baseUrl/seller/foods'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    final body = json.decode(res.body);
    return body is List ? body : (body['data'] as List? ?? []);
  }

  /// Create a food item (seller).
  static Future<Map<String, dynamic>> createFood(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/seller/foods'),
      headers: await _headers(auth: true),
      body: json.encode(data),
    );
    _throwIfError(res);
    return _decode(res);
  }

  /// Update a food item (seller).
  static Future<Map<String, dynamic>> updateFood(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/seller/foods/$id'),
      headers: await _headers(auth: true),
      body: json.encode(data),
    );
    _throwIfError(res);
    return _decode(res);
  }

  /// Delete a food item (seller).
  static Future<void> deleteFood(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/seller/foods/$id'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
  }

  /// Get seller's orders.
  static Future<List<dynamic>> getSellerOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/seller/orders'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    final body = json.decode(res.body);
    return body is List ? body : (body['data'] as List? ?? []);
  }

  /// Sync local orders to backend.
  static Future<List<dynamic>> syncOrders(List<Map<String, dynamic>> orders) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders/sync'),
      headers: await _headers(auth: true),
      body: json.encode({'orders': orders}),
    );
    _throwIfError(res);
    final body = json.decode(res.body);
    return body is List ? body : (body['data'] as List? ?? []);
  }

  /// Get all orders.
  static Future<List<dynamic>> getAllOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/all'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    final body = json.decode(res.body);
    return body is List ? body : (body['data'] as List? ?? []);
  }

  /// Get seller stats.
  static Future<Map<String, dynamic>> getSellerStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/seller/stats'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    return _decode(res);
  }
}

// ---------------------------------------------------------------------------
// ApiException
// ---------------------------------------------------------------------------

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
