import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import '../models/order_receipt.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'receipt_screen.dart';
import 'welcome_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  static const _lastLatKey = 'checkout_last_lat';
  static const _lastLngKey = 'checkout_last_lng';
  static const _lastAddressKey = 'checkout_last_address';

  /// Only used as a camera fallback when no location has ever been resolved.
  /// It is never used as the delivery location.
  static const _worldCenter = LatLng(0, 0);

  String _selectedPaymentMethod = 'ABA Pay';
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _mapController = MapController();
  final _locationService = LocationService();

  LatLng? _selectedLocation;
  LatLng _mapCenter = _worldCenter;
  bool _mapReady = false;
  bool _isBootstrapping = true;
  bool _isResolvingAddress = false;

  late final AnimationController _cameraAnimationController;
  LatLng? _cameraFrom;
  LatLng? _cameraTo;
  double _cameraZoomFrom = 16;
  double _cameraZoomTo = 16;

  Timer? _addressDebounce;
  int _addressRequestId = 0;

  String? _selectedCouponCode;
  String? _locationError;
  bool _isParsingLocation = false;
  bool _isLocating = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addListener(_onCameraAnimationTick);
    _bootstrapLocation();
  }

  String _tr(String key) =>
      Provider.of<LocaleProvider>(context, listen: false).translate(key);

  String _trArgs(String key, Map<String, String> args) =>
      Provider.of<LocaleProvider>(context, listen: false)
          .translateArgs(key, args);

  @override
  void dispose() {
    _addressDebounce?.cancel();
    _cameraAnimationController
      ..removeListener(_onCameraAnimationTick)
      ..dispose();
    _addressController.dispose();
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Location bootstrap, selection and camera animation
  // ---------------------------------------------------------------------------

  Future<void> _bootstrapLocation() async {
    final cached = await _loadCachedLocation();
    final detected = await _tryGetCurrentLocation();

    if (!mounted) return;

    final point = detected != null
        ? LatLng(detected.latitude, detected.longitude)
        : cached?.point;

    setState(() {
      _isBootstrapping = false;
      _isLocating = false;
      _mapCenter = point ?? _worldCenter;
      _selectedLocation = point;
      if (point == null) {
        _locationError ??= _tr('could_not_detect_location');
      } else {
        _locationError = null;
        if (detected == null && cached != null) {
          _addressController.text = cached.address;
        }
      }
    });

    if (detected == null || point == null) {
      // With no GPS, still try to refresh an empty cached address.
      if (detected == null && cached != null && cached.address.isEmpty) {
        unawaited(_resolveAddress(cached.point));
      }
      return;
    }

    if (detected.isApproximate && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('approximate_location')),
        ),
      );
    }

    await _resolveAddress(point);
  }

  Future<CurrentLocation?> _tryGetCurrentLocation() async {
    try {
      return await _locationService.getCurrentLocation();
    } on LocationException catch (e) {
      if (mounted) setState(() => _locationError = e.message);
      return null;
    } catch (e) {
      if (mounted) {
        setState(() => _locationError =
            _trArgs('could_not_get_location', {'error': '$e'}));
      }
      return null;
    }
  }

  SnackBarAction? _settingsActionFor(LocationIssue issue) {
    switch (issue) {
      case LocationIssue.permissionDeniedForever:
        return SnackBarAction(
          label: _tr('action_settings'),
          onPressed: () => unawaited(_locationService.openAppSettings()),
        );
      case LocationIssue.serviceDisabled:
        return SnackBarAction(
          label: _tr('action_enable'),
          onPressed: () => unawaited(_locationService.openLocationSettings()),
        );
      case LocationIssue.permissionDenied:
      case LocationIssue.unavailable:
        return null;
    }
  }

  void _onCameraAnimationTick() {
    final from = _cameraFrom;
    final to = _cameraTo;
    if (from == null || to == null || !_mapReady) return;

    final t = Curves.easeInOutCubic.transform(_cameraAnimationController.value);
    final center = LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
    _mapController.move(
      center,
      _cameraZoomFrom + (_cameraZoomTo - _cameraZoomFrom) * t,
    );
  }

  void _animateCameraTo(LatLng target, {double zoom = 16}) {
    if (!_mapReady) {
      setState(() => _mapCenter = target);
      return;
    }
    _cameraFrom = _mapController.camera.center;
    _cameraTo = target;
    _cameraZoomFrom = _mapController.camera.zoom;
    _cameraZoomTo = zoom;
    _cameraAnimationController.forward(from: 0);
  }

  void _setSelectedLocation(LatLng point) {
    setState(() {
      _selectedLocation = point;
      _locationError = null;
    });
    // Persist the point now; the address is saved once it is resolved.
    _persistPoint(point);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    _setSelectedLocation(point);
    _scheduleAddressLookup(point);
  }

  void _onPinDrag(DragUpdateDetails details) {
    final current = _selectedLocation;
    if (current == null || !_mapReady) return;

    final camera = _mapController.camera;
    final screenPoint = camera.latLngToScreenOffset(current);
    final next = camera.screenOffsetToLatLng(screenPoint + details.delta);

    // Invalidate any in-flight lookup; the address is refreshed when the drag
    // ends so we don't spam the geocoder for every pixel moved.
    _addressRequestId++;
    setState(() {
      _selectedLocation = next;
      _isResolvingAddress = false;
      _locationError = null;
    });
  }

  void _onPinDragEnd() {
    final point = _selectedLocation;
    if (point == null) return;
    _persistPoint(point);
    _scheduleAddressLookup(point);
  }

  void _scheduleAddressLookup(LatLng point) {
    _addressDebounce?.cancel();
    _addressDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _resolveAddress(point),
    );
  }

  Future<void> _resolveAddress(LatLng point) async {
    final requestId = ++_addressRequestId;

    if (mounted) setState(() => _isResolvingAddress = true);

    final address = await _locationService.reverseGeocode(
      point.latitude,
      point.longitude,
    );

    if (!mounted || requestId != _addressRequestId) return;

    final fallback =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    final resolved = address != null && address.isNotEmpty ? address : fallback;

    setState(() {
      _addressController.text = resolved;
      _isResolvingAddress = false;
    });

    await _persistLocation(point, resolved);
  }

  Future<_CachedLocation?> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_lastLatKey);
      final lng = prefs.getDouble(_lastLngKey);
      if (lat == null || lng == null) return null;
      return _CachedLocation(
        point: LatLng(lat, lng),
        address: prefs.getString(_lastAddressKey) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistPoint(LatLng point) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_lastLatKey, point.latitude);
      await prefs.setDouble(_lastLngKey, point.longitude);
      // The previously saved address belongs to the previous point.
      await prefs.remove(_lastAddressKey);
    } catch (_) {
      // Persisting is a convenience only; never block checkout on it.
    }
  }

  Future<void> _persistLocation(LatLng point, String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_lastLatKey, point.latitude);
      await prefs.setDouble(_lastLngKey, point.longitude);
      await prefs.setString(_lastAddressKey, address);
    } catch (_) {
      // Persisting is a convenience only; never block checkout on it.
    }
  }

  Widget _buildMapPlaceholder(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23233A) : const Color(0xFFF2EFE9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.orangeAccent),
            const SizedBox(height: 12),
            Text(
              _tr('detecting_location'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapStatusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDeliveryPin() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Icon(
        Icons.location_on,
        color: Colors.red,
        size: 48,
        shadows: const [
          Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
    );
  }


  /// Extracts coordinates from Google Maps URL patterns.
  LatLng? _extractCoordsFromUrl(String url) {
    final patterns = [
      RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)'),          // @lat,lng
      RegExp(r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)'),      // !3dlat!4dlng
      RegExp(r'[?&]q=(-?\d+\.?\d*),(-?\d+\.?\d*)'),     // ?q=lat,lng
      RegExp(r'/place/(-?\d+\.?\d*),(-?\d+\.?\d*)'),     // /place/lat,lng
      RegExp(r'[?&]ll=(-?\d+\.?\d*),(-?\d+\.?\d*)'),     // ?ll=lat,lng
      RegExp(r'[?&]center=(-?\d+\.?\d*),(-?\d+\.?\d*)'), // ?center=lat,lng
      RegExp(r'[?&]destination=(-?\d+\.?\d*),(-?\d+\.?\d*)'), // destination=
      RegExp(r'[?&]daddr=(-?\d+\.?\d*),(-?\d+\.?\d*)'),  // daddr=lat,lng
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        final lat = double.tryParse(match.group(1)!);
        final lng = double.tryParse(match.group(2)!);
        if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180) {
          return LatLng(lat, lng);
        }
      }
    }
    return null;
  }

  /// Parses raw coordinate text like "11.546209, 104.853187".
  LatLng? _parseRawCoords(String text) {
    final coordRegex = RegExp(r'^\s*(-?\d+\.?\d*)\s*[,\s]\s*(-?\d+\.?\d*)\s*$');
    final match = coordRegex.firstMatch(text);
    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180) {
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  /// Follows redirect chain for shortened URLs (up to [maxRedirects] hops).
  Future<String?> _resolveRedirects(String url, {int maxRedirects = 10}) async {
    final client = http.Client();
    try {
      String currentUrl = url;
      for (int i = 0; i < maxRedirects; i++) {
        final request = http.Request('GET', Uri.parse(currentUrl));
        request.followRedirects = false;
        final response = await client.send(request).timeout(const Duration(seconds: 10));
        // Drain the response body to free resources
        await response.stream.drain();

        final location = response.headers['location'];
        if (location == null || location.isEmpty) {
          return currentUrl;
        }
        // Handle relative redirects
        final resolved = Uri.parse(currentUrl).resolve(location).toString();
        currentUrl = resolved;

        // If we found a full Google Maps URL, return it early
        if (_extractCoordsFromUrl(currentUrl) != null) {
          return currentUrl;
        }
      }
      return currentUrl;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  Future<void> _parseLocation() async {
    final input = _locationController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _locationError = null;
      _isParsingLocation = true;
    });

    LatLng? parsed;

    // Check if input is a URL
    final isUrl = input.startsWith('http://') || input.startsWith('https://');

    if (isUrl) {
      // Try to extract coords from the URL directly first
      parsed = _extractCoordsFromUrl(input);

      // If it's a shortened/redirect URL, follow the redirect chain
      if (parsed == null) {
        final resolvedUrl = await _resolveRedirects(input);
        if (resolvedUrl != null && resolvedUrl != input) {
          parsed = _extractCoordsFromUrl(resolvedUrl);
        }
      }
    } else {
      // Not a URL — treat as raw coordinates
      parsed = _parseRawCoords(input);
    }

    if (!mounted) return;

    if (parsed != null) {
      setState(() {
        _locationError = null;
        _isParsingLocation = false;
      });
      _setSelectedLocation(parsed);
      _animateCameraTo(parsed);
      unawaited(_resolveAddress(parsed));
    } else {
      setState(() {
        _locationError = _tr('could_not_extract_location');
        _isParsingLocation = false;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (!mounted) return;

      final loc = LatLng(location.latitude, location.longitude);
      _setSelectedLocation(loc);
      _animateCameraTo(loc);

      if (location.isApproximate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr('approximate_location')),
          ),
        );
      }

      unawaited(_resolveAddress(loc));
    } on LocationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: _settingsActionFor(e.issue),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_trArgs('could_not_get_location', {'error': '$e'}))),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  String _couponLabel(String code, double rate) {
    if (rate == 0.0) return '$code — ${_tr('free_shipping')}';
    return '$code — ${_trArgs('percent_off', {'percent': '${(rate * 100).toInt()}'})}';
  }

  void _onCouponChanged(CartProvider cart, String? value) {
    setState(() {
      _selectedCouponCode = value;
    });
    if (value == null) {
      cart.clearCoupon();
    } else {
      cart.applyCoupon(value);
    }
  }

  void _showQRDialog(BuildContext screenContext, CartProvider cart) {
    final localeProvider =
        Provider.of<LocaleProvider>(screenContext, listen: false);
    final discountedTotal = cart.totalAfterDiscount;

    showDialog(
      context: screenContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Column(
          children: [
            Text(_selectedPaymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              localeProvider.translate('scan_to_pay'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=MOCK_KHQR_PAYMENT_$discountedTotal',
                height: 200,
                width: 200,
                errorBuilder: (ctx, error, stackTrace) => const Icon(Icons.qr_code_2, size: 200),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '\$${discountedTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localeProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _processOrder(screenContext, cart);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              localeProvider.translate('i_have_paid'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder(BuildContext context, CartProvider cart) async {
    final location = _selectedLocation;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('set_location_first')),
        ),
      );
      return;
    }

    final deliveryAddress = _addressController.text.trim().isEmpty
        ? '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}'
        : _addressController.text.trim();

    setState(() => _isProcessing = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final subtotal = cart.totalAmount;
      final discountAmount = cart.discountAmount;
      final totalToPay = cart.totalAfterDiscount;

      final receipt = OrderReceipt(
        id: const Uuid().v4(),
        items: cart.items.values.toList(),
        subtotal: subtotal,
        discountAmount: discountAmount,
        couponCode: cart.selectedCouponCode.isEmpty ? null : cart.selectedCouponCode,
        totalAmount: totalToPay,
        date: DateTime.now(),
        deliveryAddress: deliveryAddress,
        latitude: location.latitude,
        longitude: location.longitude,
        paymentMethod: _selectedPaymentMethod,
      );

      try {
        final orderData = {
          'items': cart.items.values.map((ci) => {
            'food_item_id': int.tryParse(ci.foodItem.id) ?? 0,
            'quantity': ci.quantity,
          }).toList(),
          'delivery_address': deliveryAddress,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'payment_method': _selectedPaymentMethod,
          'coupon_code': cart.selectedCouponCode.isEmpty ? null : cart.selectedCouponCode,
          'discount_amount': discountAmount,
          'total_amount': totalToPay,
        };
        await ApiService.placeOrder(orderData);
      } catch (e) {
        if (!mounted) return;
        final isAuth = e.toString().contains('401') || e.toString().contains('Unauthenticated');
        if (isAuth) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tr('session_expired')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: _tr('logout'),
                textColor: Colors.white,
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          );
          return;
        } else {
          final serverUrl = ApiService.baseUrl;
          final statusCode = e is ApiException ? '${e.statusCode}' : 'N/A';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_trArgs('backend_unreachable', {
                'url': serverUrl,
                'status': statusCode,
                'error': '$e',
              })),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 10),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      await authProvider.addOrderToHistory(receipt);
      cart.clear();
      cart.clearCoupon();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ReceiptScreen(receipt: receipt)),
        (route) => route.isFirst,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr('checkout'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                _tr('select_delivery_location'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: _tr('paste_maps_link'),
                  hintText: _tr('maps_link_hint'),
                  prefixIcon: const Icon(Icons.link, color: Colors.orangeAccent),
                  suffixIcon: _isParsingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search, color: Colors.orangeAccent),
                          onPressed: _parseLocation,
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onSubmitted: (_) => _parseLocation(),
              ),
            ),
            if (_locationError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _locationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.width > 600 ? 400 : 250,
              child: _isBootstrapping
                  ? _buildMapPlaceholder(isDark)
                  : Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _mapCenter,
                                initialZoom: _selectedLocation == null ? 2 : 16,
                                minZoom: 2,
                                maxZoom: 19,
                                onMapReady: () {
                                  if (mounted) setState(() => _mapReady = true);
                                },
                                onTap: _onMapTap,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.food',
                                ),
                                MarkerLayer(
                                  markers: [
                                    if (_selectedLocation != null)
                                      Marker(
                                        point: _selectedLocation!,
                                        width: 64,
                                        height: 64,
                                        alignment: Alignment.topCenter,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {},
                                          onPanUpdate: _onPinDrag,
                                          onPanEnd: (_) => _onPinDragEnd(),
                                          onPanCancel: _onPinDragEnd,
                                          child: _buildDeliveryPin(),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isLocating)
                          Positioned(
                            top: 8,
                            left: 23,
                            child: _buildMapStatusChip(_tr('finding_location')),
                          )
                        else if (_isResolvingAddress)
                          Positioned(
                            top: 8,
                            left: 23,
                            child: _buildMapStatusChip(_tr('updating_address')),
                          ),
                        Positioned(
                          right: 23,
                          bottom: 8,
                          child: FloatingActionButton.small(
                            heroTag: 'myLocation',
                            tooltip: _tr('use_my_location'),
                            onPressed: _isLocating ? null : _goToCurrentLocation,
                            backgroundColor: Colors.white,
                            child: _isLocating
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.my_location, color: Colors.orangeAccent),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: _tr('delivery_address_label'),
                  hintText: _tr('tap_map_or_drag'),
                  helperText: _selectedLocation == null
                      ? null
                      : _trArgs('lat_lng', {
                          'lat': _selectedLocation!.latitude.toStringAsFixed(6),
                          'lng': _selectedLocation!.longitude.toStringAsFixed(6),
                        }),
                  helperMaxLines: 1,
                  prefixIcon: const Icon(Icons.home_outlined),
                  suffixIcon: _isResolvingAddress
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: DropdownButtonFormField<String?>(
                value: _selectedCouponCode,
                decoration: InputDecoration(
                  labelText: _tr('select_coupon'),
                  prefixIcon: const Icon(Icons.card_giftcard, color: Colors.orangeAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                isExpanded: true,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(_tr('no_coupon')),
                  ),
                  ...cart.availableCoupons.entries.map((entry) {
                    return DropdownMenuItem<String?>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.value == 0.0
                                  ? _tr('free_ship')
                                  : _trArgs('percent_off', {
                                      'percent':
                                          '${(entry.value * 100).toInt()}',
                                    }),
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) => _onCouponChanged(cart, value),
              ),
            ),
            if (_selectedCouponCode != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _couponLabel(_selectedCouponCode!, cart.availableCoupons[_selectedCouponCode!] ?? 0),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                _tr('payment_method_label'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('ABA Pay'),
              leading: Radio<String>(
                value: 'ABA Pay',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              ),
              trailing: const Icon(Icons.account_balance_wallet, color: Colors.blue),
            ),
            ListTile(
              title: const Text('ACLEDA KHQR'),
              leading: Radio<String>(
                value: 'ACLEDA KHQR',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              ),
              trailing: const Icon(Icons.qr_code_scanner, color: Colors.blue),
            ),
            ListTile(
              title: Text(_tr('cash_on_delivery')),
              leading: Radio<String>(
                value: 'Cash on Delivery',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              ),
              trailing: const Icon(Icons.money, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_tr('subtotal'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (cart.selectedCouponCode.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_trArgs('discount_with_code', {'code': cart.selectedCouponCode}), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '-\$${cart.discountAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_tr('total_to_pay'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${cart.totalAfterDiscount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              if (_selectedPaymentMethod == 'ABA Pay' || _selectedPaymentMethod == 'ACLEDA KHQR') {
                                _showQRDialog(context, cart);
                              } else {
                                _processOrder(context, cart);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _tr('pay_now'),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _CachedLocation {
  final LatLng point;
  final String address;

  const _CachedLocation({required this.point, required this.address});
}
