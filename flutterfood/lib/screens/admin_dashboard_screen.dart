import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Redirect if not admin (though we should handle this at navigation level too)
    if (!authProvider.isAdmin) {
      return Scaffold(
        body: Center(
          child: Text(localeProvider.translate('access_denied_admin')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localeProvider.translate('admin_dashboard'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeProvider.translate('order_lifecycle'),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildFlowchart(context),
            const SizedBox(height: 40),
            _buildQuickStats(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFlowchart(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return Column(
      children: [
        _buildFlowStep(
          context,
          localeProvider.translate('order_placed'),
          localeProvider.translate('order_placed_desc'),
          Icons.shopping_bag,
          Colors.blue,
          isFirst: true,
        ),
        _buildFlowLine(Colors.blue),
        _buildFlowStep(
          context,
          localeProvider.translate('payment_confirmed'),
          localeProvider.translate('payment_confirmed_desc'),
          Icons.payment,
          Colors.green,
        ),
        _buildFlowLine(Colors.green),
        _buildFlowStep(
          context,
          localeProvider.translate('preparing_food'),
          localeProvider.translate('preparing_food_desc'),
          Icons.restaurant,
          Colors.orange,
        ),
        _buildFlowLine(Colors.orange),
        _buildFlowStep(
          context,
          localeProvider.translate('out_for_delivery'),
          localeProvider.translate('out_for_delivery_desc'),
          Icons.delivery_dining,
          Colors.purple,
        ),
        _buildFlowLine(Colors.purple),
        _buildFlowStep(
          context,
          localeProvider.translate('delivered'),
          localeProvider.translate('delivered_desc'),
          Icons.check_circle,
          Colors.teal,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildFlowStep(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlowLine(Color color) {
    return Container(
      width: 60,
      alignment: Alignment.center,
      child: Container(
        width: 2,
        height: 40,
        color: color.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localeProvider.translate('quick_stats'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildStatCard(context, localeProvider.translate('total_orders'), '1,234', Icons.list_alt, Colors.blue),
            const SizedBox(width: 15),
            _buildStatCard(context, localeProvider.translate('revenue'), '\$12,345', Icons.attach_money, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
