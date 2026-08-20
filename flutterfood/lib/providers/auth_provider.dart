import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/order_receipt.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isInitialized = false;
  String? _lastError;

  AuthProvider() {
    _loadUser();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get isSeller => _user?.role == UserRole.seller;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      try {
        final decodedData = json.decode(userData);
        _user = User.fromMap(decodedData);
        await _restoreProfilePic();
        await _loadOrderHistory();
      } catch (_) {}
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(_user!.toMap()));
    if (_user!.profilePic.isNotEmpty) {
      await prefs.setString('profile_pic_${_user!.email}', _user!.profilePic);
    }
  }

  Future<void> _restoreProfilePic() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('profile_pic_${_user!.email}');
    if (saved != null && saved.isNotEmpty) {
      _user = _user!.copyWith(profilePic: saved);
    }
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  Future<bool> login(String email, String password) async {
    _lastError = null;
    try {
      final data = await ApiService.login(email, password);
      final userMap = (data['user'] ?? data['data']?['user'] ?? data) as Map<String, dynamic>;
      _user = User.fromApiMap(userMap);
      await _restoreProfilePic();
      await _saveUser();
      await _loadOrderHistory();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      // Fallback to mock accounts if API is unreachable (offline dev mode)
      final mockResult = await _mockLogin(email, password);
      if (!mockResult && _lastError == null) {
        _lastError = 'Connection failed. Check server URL or try again later.';
        notifyListeners();
      }
      return mockResult;
    }
  }

  Future<bool> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mockAccounts = {
      'customer@example.com': {'id': 'customer@example.com', 'name': 'Happy Customer', 'role': UserRole.customer},
      'seller@example.com': {'id': 'seller@example.com', 'name': 'Best Seller', 'role': UserRole.seller},
      'admin@example.com': {'id': 'admin@example.com', 'name': 'System Admin', 'role': UserRole.admin},
      'customer@food.com': {'id': 'customer@food.com', 'name': 'Happy Customer', 'role': UserRole.customer},
      'seller@food.com': {'id': 'seller@food.com', 'name': 'Best Seller', 'role': UserRole.seller},
      'admin@food.com': {'id': 'admin@food.com', 'name': 'System Admin', 'role': UserRole.admin},
    };

    if (password == 'password' && mockAccounts.containsKey(email)) {
      final account = mockAccounts[email]!;
      _user = User(
        id: account['id'] as String,
        email: email,
        name: account['name'] as String,
        role: account['role'] as UserRole,
      );
      await _restoreProfilePic();
      await _saveUser();
      await _loadOrderHistory();
      notifyListeners();
      return true;
    }

    // Check stored registered users
    final prefs = await SharedPreferences.getInstance();
    final registeredUsersJson = prefs.getString('registered_users') ?? '[]';
    final List<dynamic> registeredUsers = json.decode(registeredUsersJson);

    final userMap = registeredUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => null,
    );

    if (userMap != null) {
      _user = User.fromMap(userMap);
      await _restoreProfilePic();
      await _saveUser();
      await _loadOrderHistory();
      notifyListeners();
      return true;
    }

    _lastError = 'Invalid credentials';
    notifyListeners();
    return false;
  }

  Future<void> register(String name, String email, String password, UserRole role, {String? phoneNumber, String? address}) async {
    _lastError = null;
    try {
      String apiRole;
      switch (role) {
        case UserRole.admin:
          apiRole = 'admin';
          break;
        case UserRole.seller:
          apiRole = 'seller';
          break;
        default:
          apiRole = 'user';
      }
      final data = await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: apiRole,
      );
      final userMap = (data['user'] ?? data['data']?['user'] ?? data) as Map<String, dynamic>;
      _user = User.fromApiMap(userMap);
      await _restoreProfilePic();
    } catch (e) {
      _lastError = e.toString();
      // Fallback mock
      _user = User(id: email, email: email, name: name, role: role, phoneNumber: phoneNumber ?? '', address: address ?? '');
      await _restoreProfilePic();
      final prefs = await SharedPreferences.getInstance();
      final json0 = prefs.getString('registered_users') ?? '[]';
      final List<dynamic> users = json.decode(json0);
      users.add({
        'id': _user!.id,
        'email': email,
        'name': name,
        'role': role.toString(),
        'password': password,
      });
      await prefs.setString('registered_users', json.encode(users));
    }
    await _saveUser();
    await _loadOrderHistory();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    _user = null;
    _orderHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? phoneNumber, String? address, String? profilePic}) async {
    if (_user == null) return;
    User? apiUser;
    try {
      final updated = await ApiService.updateProfile({
        if (name != null) 'name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (address != null) 'address': address,
      });
      apiUser = User.fromApiMap(updated['user'] as Map<String, dynamic>? ?? updated);
    } catch (_) {}
    _user = (apiUser ?? _user)!.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      profilePic: profilePic,
    );
    await _saveUser();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Order History
  // ---------------------------------------------------------------------------

  final List<OrderReceipt> _orderHistory = [];
  List<OrderReceipt> get orderHistory => [..._orderHistory];

  Future<void> addOrderToHistory(OrderReceipt receipt) async {
    _orderHistory.insert(0, receipt);
    await _saveOrderHistory();
    notifyListeners();
  }

  Future<void> _saveOrderHistory() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'order_history_${_user!.id}',
      json.encode(_orderHistory.map((r) => r.toMap()).toList()),
    );
  }

  Future<void> _loadOrderHistory() async {
    _orderHistory.clear();
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('order_history_${_user!.id}');
    if (stored != null) {
      try {
        final List<dynamic> decoded = json.decode(stored);
        _orderHistory.addAll(
          decoded.map((item) => OrderReceipt.fromMap(Map<String, dynamic>.from(item))),
        );
      } catch (_) {}
    }
  }
}
