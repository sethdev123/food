import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/profile_avatar.dart';
import '../models/user.dart';
import 'receipt_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _addressController.text = user?.address ?? '';
  }

  void _saveProfile() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    await Provider.of<AuthProvider>(context, listen: false).updateProfile(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      profilePic: user?.profilePic,
    );
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localeProvider.translate('profile_updated'))),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _updateAvatar(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        final localeProvider =
            Provider.of<LocaleProvider>(context, listen: false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localeProvider.translateArgs(
              'failed_pick_image',
              {'error': '$e'},
            )),
          ),
        );
      }
    }
  }

  void _updateAvatar(String path) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await authProvider.updateProfile(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      profilePic: path,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localeProvider.translate('profile_pic_updated'))),
      );
    }
  }

  void _showChangePicBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final localeProvider = Provider.of<LocaleProvider>(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  localeProvider.translate('select_profile_picture'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickOption(
                      icon: Icons.photo_library,
                      label: localeProvider.translate('gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    _buildPickOption(
                      icon: Icons.camera_alt,
                      label: localeProvider.translate('camera'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  localeProvider.translate('or_choose_avatar'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPresetAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Felix'),
                      _buildPresetAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Aneka'),
                      _buildPresetAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Aria'),
                      _buildPresetAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Jack'),
                      _buildPresetAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Sophia'),
                      _buildPresetAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Oliver'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.orangeAccent),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetAvatarOption(String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          _updateAvatar(url);
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3), width: 2),
          ),
          child: ClipOval(
            child: Image.network(
              url,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localeProvider.translate('profile'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: const Icon(Icons.person), text: localeProvider.translate('info')),
            Tab(icon: const Icon(Icons.history), text: localeProvider.translate('orders')),
            Tab(icon: const Icon(Icons.card_giftcard), text: localeProvider.translate('coupons')),
          ],
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(user),
            _buildOrdersTab(authProvider),
            _buildCouponsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(User? user) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: ProfileAvatar(
              profilePic: user?.profilePic ?? '',
              name: user?.name ?? '',
              radius: 60,
              showEditIcon: true,
              onTap: _showChangePicBottomSheet,
            ),
          ),
          const SizedBox(height: 30),
          _buildEditableField(Icons.person, localeProvider.translate('name'), _nameController),
          const SizedBox(height: 15),
          _buildEditableField(Icons.phone, localeProvider.translate('phone_number'), _phoneController),
          const SizedBox(height: 15),
          _buildEditableField(Icons.location_on, localeProvider.translate('address'), _addressController),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? Colors.green : Colors.orangeAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                _isEditing
                    ? localeProvider.translate('save_changes')
                    : localeProvider.translate('edit_profile'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(IconData icon, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orangeAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildOrdersTab(AuthProvider auth) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final orders = auth.orderHistory;
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              localeProvider.translate('no_orders_yet'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(localeProvider.translateArgs(
              'order_number',
              {'id': order.id.substring(0, 8).toUpperCase()},
            )),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(order.date)),
            trailing: Text(
              '\$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReceiptScreen(receipt: order)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCouponsTab() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final List<Map<String, String>> coupons = [
      {'code': 'MEMBER20', 'percent': '20', 'desc': 'membership_discount'},
      {'code': 'PREMIUM40', 'percent': '40', 'desc': 'premium_member_discount'},
      {'code': 'FOODIE20', 'percent': '20', 'desc': 'special_promo'},
      {'code': 'FREE_SHIP', 'free': 'true', 'min': '20'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        final isFree = coupon['free'] == 'true';
        final label = isFree
            ? localeProvider.translate('free_delivery')
            : localeProvider.translateArgs(
                'percent_off',
                {'percent': coupon['percent']!},
              );
        final desc = isFree
            ? localeProvider.translateArgs(
                'min_spend',
                {'amount': coupon['min']!},
              )
            : localeProvider.translate(coupon['desc']!);
        return Card(
          color: Colors.orange[50],
          child: ListTile(
            leading: const Icon(Icons.confirmation_number, color: Colors.orangeAccent),
            title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(desc),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.orangeAccent),
              ),
              child: Text(coupon['code']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            ),
          ),
        );
      },
    );
  }
}
