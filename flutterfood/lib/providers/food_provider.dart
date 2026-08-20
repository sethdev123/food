import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class FoodProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<FoodItem> _items = [
    // Burgers
    FoodItem(
      id: '1',
      name: 'Classic Beef Burger',
      price: 12.99,
      description: 'Juicy prime beef patty, cheddar, lettuce, tomato, house sauce.',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
      category: 'Burgers',
    ),
    FoodItem(
      id: '2',
      name: 'Cheese Bacon Burger',
      price: 14.50,
      description: 'Double cheese, crispy bacon strips, caramelized onions, BBQ glaze.',
      imageUrl: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?auto=format&fit=crop&w=600&q=80',
      category: 'Burgers',
    ),
    FoodItem(
      id: '3',
      name: 'Spicy Crispy Chicken Burger',
      price: 11.99,
      description: 'Zesty fried chicken breast, spicy mayo, pickles, shredded lettuce.',
      imageUrl: 'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?auto=format&fit=crop&w=600&q=80',
      category: 'Burgers',
    ),

    // Pizza
    FoodItem(
      id: '4',
      name: 'Margherita Pizza',
      price: 15.50,
      description: 'Classic Italian pizza with tomato sauce, fresh mozzarella, and sweet basil.',
      imageUrl: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?auto=format&fit=crop&w=600&q=80',
      category: 'Pizza',
    ),
    FoodItem(
      id: '5',
      name: 'Pepperoni Feast Pizza',
      price: 17.99,
      description: 'Loaded with double spicy pepperoni and premium mozzarella cheese.',
      imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=600&q=80',
      category: 'Pizza',
    ),
    FoodItem(
      id: '6',
      name: 'BBQ Chicken Pizza',
      price: 16.99,
      description: 'Tender chicken pieces, smoky BBQ sauce, red onion, cilantro, and mozzarella.',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80',
      category: 'Pizza',
    ),

    // Salads
    FoodItem(
      id: '7',
      name: 'Caesar Salad',
      price: 9.99,
      description: 'Fresh romaine lettuce, Caesar dressing, garlic croutons, parmesan flakes.',
      imageUrl: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=600&q=80',
      category: 'Salads',
    ),
    FoodItem(
      id: '8',
      name: 'Greek Feta Salad',
      price: 10.50,
      description: 'Crispy cucumber, tomatoes, olives, red onion, premium Greek feta cheese.',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80',
      category: 'Salads',
    ),
    FoodItem(
      id: '9',
      name: 'Quinoa Avocado Salad',
      price: 11.99,
      description: 'Healthy quinoa mix with fresh avocado, cherry tomatoes, and citrus dressing.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80',
      category: 'Salads',
    ),

    // Japanese
    FoodItem(
      id: '10',
      name: 'Sushi Platter',
      price: 24.99,
      description: 'Assorted premium sushi rolls, nigiri, and fresh salmon sashimi.',
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=600&q=80',
      category: 'Japanese',
    ),
    FoodItem(
      id: '11',
      name: 'Tonkotsu Ramen',
      price: 16.50,
      description: 'Rich pork broth ramen, tender chashu pork slices, soft-boiled egg, and nori.',
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
      category: 'Japanese',
    ),
    FoodItem(
      id: '12',
      name: 'Chicken Katsu Curry',
      price: 15.99,
      description: 'Crispy breaded chicken cutlet with rich Japanese curry sauce over rice.',
      imageUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=600&q=80',
      category: 'Japanese',
    ),

    // Pasta
    FoodItem(
      id: '13',
      name: 'Pasta Carbonara',
      price: 14.50,
      description: 'Creamy pasta with pan-fried pancetta, fresh egg yolk, and parmesan cheese.',
      imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&w=600&q=80',
      category: 'Pasta',
    ),
    FoodItem(
      id: '14',
      name: 'Seafood Spaghetti Marinara',
      price: 18.99,
      description: 'Spaghetti tossed with shrimp, mussels, and squid in rich tomato garlic sauce.',
      imageUrl: 'https://images.unsplash.com/photo-1563379971899-660589a01ec3?auto=format&fit=crop&w=600&q=80',
      category: 'Pasta',
    ),
    FoodItem(
      id: '15',
      name: 'Creamy Mushroom Fettuccine',
      price: 13.99,
      description: 'Fettuccine pasta in rich creamy garlic sauce with sautéed mushrooms.',
      imageUrl: 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?auto=format&fit=crop&w=600&q=80',
      category: 'Pasta',
    ),

    // Mexican
    FoodItem(
      id: '16',
      name: 'Spicy Beef Tacos',
      price: 11.50,
      description: 'Three crispy tacos filled with spiced ground beef, cheese, lettuce, and salsa.',
      imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=600&q=80',
      category: 'Mexican',
    ),
    FoodItem(
      id: '17',
      name: 'Grilled Chicken Burrito',
      price: 12.50,
      description: 'Large flour tortilla rolled with chicken, rice, black beans, guacamole, and cream.',
      imageUrl: 'https://images.unsplash.com/photo-1626379616459-b2ce1d9decda?auto=format&fit=crop&w=600&q=80',
      category: 'Mexican',
    ),
    FoodItem(
      id: '18',
      name: 'Loaded Cheese Quesadilla',
      price: 10.99,
      description: 'Toasted tortilla filled with melted mozzarella, cheddar, bell peppers, and jalapeños.',
      imageUrl: 'https://images.unsplash.com/photo-1615870216519-2f9fa575fa5c?auto=format&fit=crop&w=600&q=80',
      category: 'Mexican',
    ),

    // Desserts
    FoodItem(
      id: '19',
      name: 'Chocolate Fudge Cake',
      price: 7.99,
      description: 'Rich, moist chocolate cake with warm chocolate fudge layers.',
      imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=600&q=80',
      category: 'Desserts',
    ),
    FoodItem(
      id: '20',
      name: 'Strawberry Cheesecake',
      price: 8.50,
      description: 'New York style cheesecake topped with sweet strawberry compote.',
      imageUrl: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80',
      category: 'Desserts',
    ),
    FoodItem(
      id: '21',
      name: 'Warm Waffles with Ice Cream',
      price: 8.99,
      description: 'Fresh baked waffles served with vanilla ice cream and maple syrup.',
      imageUrl: 'https://images.unsplash.com/photo-1562376502-6f769499c886?auto=format&fit=crop&w=600&q=80',
      category: 'Desserts',
    ),

    // Drinks
    FoodItem(
      id: '22',
      name: 'Strawberry Matcha Latte',
      price: 6.25,
      description: 'Layered premium Uji matcha, fresh strawberries purée, and creamy milk.',
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '23',
      name: 'Coconut Matcha Latte',
      price: 6.50,
      description: 'Zesty coconut milk layered with stone-ground green tea matcha.',
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '24',
      name: 'Creamy Chocolate Milk',
      price: 4.99,
      description: 'Rich Belgian chocolate sauce blended with cold, creamy organic milk.',
      imageUrl: 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '25',
      name: 'Iced Matcha Latte',
      price: 5.50,
      description: 'Ceremonial grade matcha whisked with cold milk and sweet honey over ice.',
      imageUrl: 'https://images.unsplash.com/photo-1594761053050-b11022d8de46?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '26',
      name: 'Fresh Strawberry Mojito',
      price: 6.50,
      description: 'Refreshing blend of muddled strawberries, mint leaves, lime juice, and soda.',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '27',
      name: 'Creamy Mango Smoothie',
      price: 5.99,
      description: 'Blend of sweet ripe mangoes, Greek yogurt, and fresh milk.',
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '28',
      name: 'Classic Iced Americano',
      price: 3.99,
      description: 'Espresso shots topped with cold water and served over ice.',
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '29',
      name: 'Caramel Macchiato',
      price: 5.75,
      description: 'Freshly steamed milk with vanilla-flavored syrup, marked with espresso and caramel drizzle.',
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '30',
      name: 'Sweet Cream Cold Brew',
      price: 4.85,
      description: 'Slow-steeped cold brew coffee served with a splash of sweet vanilla cream.',
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '31',
      name: 'Taro Bubble Tea',
      price: 5.50,
      description: 'Sweet and creamy purple taro root milk tea with chewy tapioca boba.',
      imageUrl: 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '32',
      name: 'Brown Sugar Boba Milk',
      price: 5.95,
      description: 'Chewy brown sugar boba pearls served with fresh cold milk and cream cheese foam.',
      imageUrl: 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '33',
      name: 'Thai Iced Tea',
      price: 4.99,
      description: 'Sweet, strongly brewed black tea flavored with star anise and topped with half-and-half.',
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '34',
      name: 'Iced Peach Green Tea',
      price: 4.50,
      description: 'Chilled green tea infused with natural sweet peach juice and a hint of mint.',
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '35',
      name: 'Passion Fruit Lemonade',
      price: 4.95,
      description: 'Zesty house-made lemonade blended with tropical passion fruit pulp.',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '36',
      name: 'Fresh Orange Juice',
      price: 4.25,
      description: '100% natural, fresh-squeezed sweet oranges rich in Vitamin C.',
      imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '37',
      name: 'Pineapple Mint Cooler',
      price: 5.25,
      description: 'Chilled sweet pineapple juice blended with fresh mint leaves and sparkling water.',
      imageUrl: 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '38',
      name: 'Sparkling Blue Lagoon',
      price: 5.50,
      description: 'Vibrant blue curaçao syrup, fresh lemonade, lime wedges, and club soda.',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '39',
      name: 'Avocado Shake',
      price: 6.50,
      description: 'Creamy ripe avocado blended with condensed milk, honey, and crushed ice.',
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '40',
      name: 'Hot Chocolate Marshmallows',
      price: 4.99,
      description: 'Rich dark hot cocoa topped with fluffy toasted mini marshmallows.',
      imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '41',
      name: 'Chai Tea Latte',
      price: 5.25,
      description: 'A blend of black tea, honey, spices, and steamed milk.',
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '42',
      name: 'London Fog Latte',
      price: 5.50,
      description: 'Earl Grey tea, vanilla syrup, and steamed milk foam.',
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '43',
      name: 'Iced Hibiscus Tea',
      price: 4.25,
      description: 'Tart and herbal hibiscus tea, lightly sweetened and served over ice.',
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '44',
      name: 'Vietnamese Iced Coffee',
      price: 5.25,
      description: 'Strong drip dark roast coffee with sweet condensed milk over ice.',
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '45',
      name: 'Raspberry Italian Soda',
      price: 4.75,
      description: 'Sparkling water mixed with sweet raspberry syrup and a splash of cream.',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '46',
      name: 'Watermelon Lime Slush',
      price: 5.50,
      description: 'Blended fresh sweet watermelon slices with lime juice and ice.',
      imageUrl: 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '47',
      name: 'Double Espresso Shot',
      price: 3.25,
      description: 'Two shots of rich espresso with golden crema.',
      imageUrl: 'https://images.unsplash.com/photo-1510701114235-fe5384c7b600?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '48',
      name: 'Mint Chocolate Shake',
      price: 6.25,
      description: 'Cool peppermint syrup, dark chocolate chips, blended with vanilla ice cream.',
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '49',
      name: 'Banana Protein Smoothie',
      price: 6.50,
      description: 'Ripe bananas, whey protein powder, almond butter, and oat milk.',
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '50',
      name: 'Blueberry Lavender Lemonade',
      price: 5.75,
      description: 'Fresh lemonade infused with house blueberry sauce and dried lavender.',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '51',
      name: 'Rose Lychee Mocktail',
      price: 5.99,
      description: 'Lychee juice, rose water syrup, sparkling soda, and mint leaves.',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '52',
      name: 'Classic Piña Colada Mocktail',
      price: 5.95,
      description: 'Smooth blend of coconut cream, pineapple juice, and crushed ice.',
      imageUrl: 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '53',
      name: 'Hot Jasmine Green Tea',
      price: 3.99,
      description: 'Fragrant hot green tea scented with sweet jasmine blossoms.',
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '54',
      name: 'Coca Cola',
      price: 2.99,
      description: 'Classic ice-cold Coca Cola served in a glass bottle.',
      imageUrl: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '55',
      name: 'Fresh Lemonade',
      price: 3.50,
      description: 'Hand-squeezed lemonade with a touch of mint and ice.',
      imageUrl: 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '56',
      name: 'Mineral Water',
      price: 1.99,
      description: 'Refreshing sparkling mineral water with a slice of lemon.',
      imageUrl: 'https://images.unsplash.com/photo-1523362628745-0c100150b504?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '57',
      name: 'Sprite',
      price: 2.99,
      description: 'Crisp, refreshing lemon-lime soda served ice cold.',
      imageUrl: 'https://images.unsplash.com/photo-1624517452488-048fb8903e1c?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
    FoodItem(
      id: '58',
      name: 'Iced Tea Peach',
      price: 3.25,
      description: 'Chilled black tea infused with sweet peach flavor.',
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      category: 'Drinks',
    ),
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<FoodItem> get items {
    return _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<FoodItem> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  List<String> get categories {
    final cats = _items.map((item) => item.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  String get selectedCategory => _selectedCategory;

  /// Fetch food items from the real API. Falls back silently to mock data.
  Future<void> fetchFoods() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getFoods();
      if (data.isNotEmpty) {
        _items.clear();
        for (final item in data) {
          _items.add(FoodItem(
            id: item['id']?.toString() ?? '',
            name: item['name'] ?? '',
            price: (item['price'] ?? 0.0) is String
                ? double.tryParse(item['price']) ?? 0.0
                : (item['price'] ?? 0.0).toDouble(),
            description: item['description'] ?? '',
            imageUrl: item['image_url'] ?? item['image'] ?? '',
            category: item['category'] ?? 'Drink',
          ));
        }
      }
    } catch (_) {
      // Silently keep mock data if API unreachable
    }
    await _restoreFavorites();
    _isLoading = false;
    notifyListeners();
  }

  Future<String> _favoritesKeyForUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData == null) return 'favorite_ids';
    try {
      final map = json.decode(userData);
      final email = map['email'] as String?;
      return email != null ? 'favorite_ids_$email' : 'favorite_ids';
    } catch (_) {
      return 'favorite_ids';
    }
  }

  Future<void> _restoreFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _favoritesKeyForUser();
    final ids = prefs.getStringList(key);
    if (ids == null) return;
    for (final item in _items) {
      if (ids.contains(item.id)) {
        item.isFavorite = true;
      }
    }
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _favoritesKeyForUser();
    final ids = _items.where((item) => item.isFavorite).map((item) => item.id).toList();
    await prefs.setStringList(key, ids);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addFood(FoodItem item) {
    _items.add(item);
    notifyListeners();
    ApiService.createFood({
      'name': item.name,
      'price': item.price,
      'description': item.description,
      'image_url': item.imageUrl,
      'category': item.category,
    }).then((data) {
      final serverId = data['id']?.toString();
      if (serverId != null) {
        final idx = _items.indexWhere((i) => i.id == item.id);
        if (idx >= 0) {
          _items[idx] = item.copyWith(id: serverId);
          notifyListeners();
        }
      }
    }).catchError((_) {});
  }

  void updateFood(String id, FoodItem newItem) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = newItem;
      notifyListeners();
    }
    final parsedId = int.tryParse(id);
    if (parsedId != null) {
      ApiService.updateFood(parsedId, {
        'name': newItem.name,
        'price': newItem.price,
        'description': newItem.description,
        'image_url': newItem.imageUrl,
        'category': newItem.category,
      }).catchError((_) => <String, dynamic>{});
    }
  }

  void deleteFood(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    final parsedId = int.tryParse(id);
    if (parsedId != null) {
      ApiService.deleteFood(parsedId).catchError((_) {});
    }
  }

  void toggleFavorite(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].isFavorite = !_items[index].isFavorite;
      _persistFavorites();
      notifyListeners();
    }
  }
}
