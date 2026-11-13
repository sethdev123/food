import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/food_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../widgets/bouncing_cart_icon.dart';
import '../widgets/cart_success_popup.dart';
import 'admin_dashboard_screen.dart';
import 'seller_dashboard_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).fetchFoods();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<FoodProvider>(context, listen: false).fetchFoods();
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: _buildDrawer(context, authProvider, localeProvider, isDark),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 88,
        centerTitle: false,
        leading: Builder(
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(8),
            child: ProfileAvatar(
              profilePic: authProvider.user?.profilePic ?? '',
              name: authProvider.user?.name ?? localeProvider.translate('guest'),
              radius: 20,
              onTap: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeProvider.translate('dashboard'),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              authProvider.user?.name != null
                  ? localeProvider.translateArgs('greeting_hi', {
                      'name': authProvider.user!.name,
                    })
                  : localeProvider.translate('welcome'),
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A65), Color(0xFFFF6D00), Color(0xFFE65100)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33FF6D00),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSearchBar(context, foodProvider, isDark),
            const SizedBox(height: 12),
            _buildCategoryChips(foodProvider, isDark, width: MediaQuery.of(context).size.width),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => foodProvider.fetchFoods(),
                child: _buildFoodGrid(foodProvider, cartProvider, isDark, width: MediaQuery.of(context).size.width),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: cartProvider.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => showCartBottomSheet(context),
              backgroundColor: Colors.orangeAccent,
              child: Badge(
                label: Text(
                  '${cartProvider.items.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.red,
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(foodProvider, cartProvider, localeProvider, isDark),
    );
  }

  Widget _buildSearchBar(BuildContext context, FoodProvider foodProvider, bool isDark) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => foodProvider.setSearchQuery(value),
          decoration: InputDecoration(
            hintText: localeProvider.translate('search_cravings'),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(FoodProvider foodProvider, bool isDark, {required double width}) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    // Calculate optimal chip count based on width
    final chipHeight = 36.0;

    return SizedBox(
      height: chipHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: foodProvider.categories.length,
        itemBuilder: (context, index) {
          final category = foodProvider.categories[index];
          final isSelected = foodProvider.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(localeProvider.translate(category), style: GoogleFonts.poppins(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
              selected: isSelected,
              onSelected: (_) => foodProvider.setCategory(category),
              selectedColor: Colors.orangeAccent,
              backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              elevation: isSelected ? 3 : 1,
              shadowColor: isSelected ? Colors.orange.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodGrid(FoodProvider foodProvider, CartProvider cartProvider, bool isDark, {required double width}) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final items = foodProvider.items;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              foodProvider.isLoading
                  ? localeProvider.translate('loading')
                  : localeProvider.translate('no_items_found'),
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    // Calculate cross axis count based on available width
    final crossAxisCount = width > 600 ? 4 : width > 400 ? 3 : 2;
    final childAspectRatio = crossAxisCount == 4 ? 0.55 : crossAxisCount == 3 ? 0.73 : 0.68;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: width > 600 ? 20 : width > 400 ? 14 : 14,
        mainAxisSpacing: width > 600 ? 20 : 14,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildFoodCard(item, foodProvider, cartProvider, isDark);
      },
    );
  }

  Widget _buildFoodCard(FoodItem item, FoodProvider foodProvider, CartProvider cartProvider, bool isDark) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, size: 40, color: Colors.orangeAccent),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => foodProvider.toggleFavorite(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black87 : Colors.white).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: item.isFavorite ? Colors.red : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeProvider.translate(item.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A65), Color(0xFFFF6D00)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        cartProvider.addItem(item);
                        showCartSuccessPopup(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        localeProvider.translate('buy'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AuthProvider authProvider,
    LocaleProvider localeProvider,
    bool isDark,
  ) {
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    return Drawer(
      child: Container(
        color: bgColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF8A65), Color(0xFFE65100)],
                ),
              ),
              accountName: Text(
                authProvider.user?.name ?? localeProvider.translate('guest'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              accountEmail: Text(
                authProvider.user?.email ?? '',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
              ),
              currentAccountPicture: ProfileAvatar(
                profilePic: authProvider.user?.profilePic ?? '',
                name: authProvider.user?.name ?? localeProvider.translate('guest'),
                radius: 36,
              ),
            ),
            _drawerItem(Icons.home, localeProvider.translate('home'), () => Navigator.pop(context)),
            _drawerItem(Icons.favorite, localeProvider.translate('favorites'), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
            }),
            if (authProvider.isAdmin)
              _drawerItem(Icons.admin_panel_settings, localeProvider.translate('admin_dashboard'), () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
              }),
            if (authProvider.isSeller)
              _drawerItem(Icons.store, localeProvider.translate('seller_dashboard'), () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SellerDashboardScreen()));
              }),
            _drawerItem(Icons.person, localeProvider.translate('profile'), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }),
            _drawerItem(Icons.settings, localeProvider.translate('settings'), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }),
            const Spacer(),
            const Divider(indent: 20, endIndent: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              title: Text(
                localeProvider.translate('logout'),
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.orangeAccent, size: 20),
      ),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildBottomNav(
    FoodProvider foodProvider,
    CartProvider cartProvider,
    LocaleProvider localeProvider,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
          selectedItemColor: Colors.orangeAccent,
          unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[500],
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          elevation: 0,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())).then(
                  (_) => setState(() => _selectedIndex = 0));
            } else if (index == 2) {
              showCartBottomSheet(context);
              setState(() => _selectedIndex = 0);
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then(
                  (_) => setState(() => _selectedIndex = 0));
            }
          },
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: localeProvider.translate('home')),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.favorite_rounded),
                  if (foodProvider.favoriteItems.isNotEmpty)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${foodProvider.favoriteItems.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: localeProvider.translate('favorites'),
            ),
            BottomNavigationBarItem(
              icon: BouncingCartIcon(count: cartProvider.items.length),
              label: localeProvider.translate('cart'),
            ),
            BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: localeProvider.translate('profile')),
          ],
        ),
      ),
    );
  }
}
