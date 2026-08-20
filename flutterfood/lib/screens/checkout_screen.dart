import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/order_receipt.dart';
import '../services/api_service.dart';
import 'receipt_screen.dart';
import 'welcome_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  LatLng _selectedLocation = const LatLng(11.5564, 104.9282); // Phnom Penh
  String _selectedPaymentMethod = 'ABA Pay';
  final _addressController = TextEditingController(text: 'Phnom Penh, Cambodia');
  final _locationController = TextEditingController();
  final _mapController = MapController();
  String? _selectedCouponCode;
  String? _locationError;
  bool _isParsingLocation = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
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
        _selectedLocation = parsed!;
        _locationError = null;
        _isParsingLocation = false;
      });
      _mapController.move(parsed, 16);
    } else {
      setState(() {
        _locationError = 'Could not extract location. Try coordinates like "11.546, 104.853" or a Google Maps link.';
        _isParsingLocation = false;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in Settings.')),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      final loc = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = loc);
      _mapController.move(loc, 16);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    }
  }

  String _couponLabel(String code, double rate) {
    if (rate == 0.0) return '$code — Free Shipping';
    return '$code — ${(rate * 100).toInt()}% OFF';
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
    final discountedTotal = cart.totalAfterDiscount;

    showDialog(
      context: screenContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Column(
          children: [
            Text(_selectedPaymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('Scan to Pay', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _processOrder(screenContext, cart);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('I Have Paid', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder(BuildContext context, CartProvider cart) async {
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
        deliveryAddress: _addressController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        paymentMethod: _selectedPaymentMethod,
      );

      try {
        final orderData = {
          'items': cart.items.values.map((ci) => {
            'food_item_id': int.tryParse(ci.foodItem.id) ?? 0,
            'quantity': ci.quantity,
          }).toList(),
          'delivery_address': _addressController.text,
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
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
              content: const Text('Session expired. Log out and log in again to place orders.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Logout',
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
              content: Text('Backend unreachable — order saved locally\nURL: $serverUrl/orders\nStatus: $statusCode\nError: $e'),
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
          'Checkout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Select Delivery Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Paste Google Maps link or coordinates',
                  hintText: 'e.g. 11.546, 104.853 or https://maps.app.goo.gl/...',
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
              height: 250,
              child: Stack(
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
                          initialCenter: _selectedLocation,
                          initialZoom: 13,
                          onTap: (tapPosition, point) {
                            setState(() => _selectedLocation = point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.food',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation,
                                width: 80,
                                height: 80,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 23,
                    bottom: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'myLocation',
                      onPressed: _goToCurrentLocation,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: Colors.orangeAccent),
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
                  labelText: 'Delivery Address',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: DropdownButtonFormField<String?>(
                value: _selectedCouponCode,
                decoration: InputDecoration(
                  labelText: 'Select Coupon',
                  prefixIcon: const Icon(Icons.card_giftcard, color: Colors.orangeAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No Coupon'),
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
                                  ? 'Free Ship'
                                  : '${(entry.value * 100).toInt()}% OFF',
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              title: const Text('Cash on Delivery'),
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
                      const Text('Subtotal:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text('Discount (${cart.selectedCouponCode}):', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      const Text('Total to Pay:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          : const Text(
                              'Pay Now',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
