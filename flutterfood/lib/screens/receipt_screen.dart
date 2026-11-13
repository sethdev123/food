import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_receipt.dart';
import '../providers/locale_provider.dart';

class ReceiptScreen extends StatelessWidget {
  final OrderReceipt receipt;

  const ReceiptScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: AppBar(
            title: Text(localeProvider.translate('order_receipt')),
            centerTitle: true,
          ),
          body: Container(
            color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                const SizedBox(height: 10),
                Text(
                  localeProvider.translate('thank_you'),
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(localeProvider.translate('order_success')),
                const SizedBox(height: 30),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(localeProvider.translate('order_id'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(receipt.id.substring(0, 8).toUpperCase(), style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Divider(height: 30),
                        ...receipt.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.quantity}x ${localeProvider.translate(item.foodItem.name)}'),
                                  Text('\$${(item.foodItem.price * item.quantity).toStringAsFixed(2)}'),
                                ],
                              ),
                            )),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(localeProvider.translate('subtotal'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '\$${receipt.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (receipt.couponCode != null && receipt.couponCode!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${localeProvider.translate('coupon')} (${receipt.couponCode}):', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                '-\$${receipt.discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(localeProvider.translate('total_amount'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '\$${receipt.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(localeProvider.translate('delivery_address'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(receipt.deliveryAddress),
                        const SizedBox(height: 15),
                        Text(localeProvider.translate('payment_method'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(localeProvider.translate(receipt.paymentMethod)),
                        const SizedBox(height: 15),
                        Text(localeProvider.translate('date'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('MMM dd, yyyy - hh:mm a').format(receipt.date)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      localeProvider.translate('back_to_home'),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}
