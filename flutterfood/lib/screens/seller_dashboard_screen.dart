import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/order_receipt.dart';
import '../services/api_service.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Load from API
    List<dynamic> apiOrders = [];
    try {
      apiOrders = await ApiService.getAllOrders();
    } catch (_) {}

    // Convert to mutable map list
    final merged = <Map<String, dynamic>>[
      ...apiOrders.cast<Map<String, dynamic>>(),
    ];

    // Read local orders
    final localOrders = auth.orderHistory;
    if (localOrders.isNotEmpty) {
      final userName = auth.user?.name ?? 'You';
      final userEmail = auth.user?.email ?? '';

      for (final r in localOrders) {
        final alreadyExists = merged.any((o) =>
            o['items'] is List &&
            (o['items'] as List).length == r.items.length &&
            (o['total_price'] as num?)?.toDouble() == r.totalAmount);

        if (!alreadyExists) {
          merged.add({
            'id': r.id,
            'status': 'pending',
            'total_price': r.totalAmount,
            'payment_method': r.paymentMethod,
            'created_at': r.date.toIso8601String(),
            'customer_name': userName,
            'customer_email': userEmail,
            'items': r.items.map((ci) => {
              'name': ci.foodItem.name,
              'quantity': ci.quantity,
              'price': ci.foodItem.price,
            }).toList(),
          });
        }
      }

      _autoSync(localOrders);
    }

    // Sort by date descending
    merged.sort((a, b) {
      final da = a['created_at'] as String? ?? a['date'] as String? ?? '';
      final db = b['created_at'] as String? ?? b['date'] as String? ?? '';
      return db.compareTo(da);
    });

    if (!mounted) return;
    setState(() {
      _orders = merged;
      _isLoading = false;
    });
  }

  Future<void> _autoSync(List<OrderReceipt> localOrders) async {
    final payload = localOrders.map((r) => {
      'id': r.id,
      'items': r.items.map((ci) => {
        'foodItem': {
          'id': ci.foodItem.id,
          'name': ci.foodItem.name,
          'price': ci.foodItem.price,
        },
        'quantity': ci.quantity,
      }).toList(),
      'totalAmount': r.totalAmount,
      'paymentMethod': r.paymentMethod,
      'date': r.date.toIso8601String(),
      'deliveryAddress': r.deliveryAddress,
    }).toList();

    try {
      await ApiService.syncOrders(payload);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recent Orders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('No orders yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders containing your food items',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.orange.withValues(alpha: 0.08)),
                headingTextStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.orange[800],
                ),
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Items Ordered')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Payment')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                ],
                rows: _orders.map((order) {
                  final items = order['items'] as List<dynamic>? ?? [];
                  final createdAt = order['created_at'] as String? ?? '';
                  final customerName = order['customer_name'] as String? ?? '';
                  final customerEmail = order['customer_email'] as String? ?? '';
                  final status = order['status'] as String? ?? 'pending';
                  final totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0;
                  final payment = order['payment_method'] as String? ?? '';

                  final itemsStr = items.map((i) => '${i['name']} \u00d7${i['quantity']}').join(', ');

                  return DataRow(
                    cells: [
                      DataCell(Text('#${order['id']}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(customerName, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text(customerEmail, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 260,
                          child: Text(itemsStr, style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                      ),
                      DataCell(Text('\$${totalPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(Text(payment, style: GoogleFonts.poppins(fontSize: 12))),
                      DataCell(_buildStatusBadge(status)),
                      DataCell(Text(_formatDate(createdAt), style: GoogleFonts.poppins(fontSize: 12))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isAccepted = status == 'pending' || status == 'completed';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: isAccepted ? Colors.green : Colors.red),
        const SizedBox(width: 4),
        Text(
          isAccepted ? 'Accepted' : 'Cancelled',
          style: GoogleFonts.poppins(fontSize: 12, color: isAccepted ? Colors.green : Colors.red),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
