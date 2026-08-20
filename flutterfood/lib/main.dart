import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/food_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const FoodApp(),
    ),
  );
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Foodie App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          primary: Colors.orangeAccent,
          secondary: Colors.greenAccent,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          primary: Colors.orangeAccent,
          secondary: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isInitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.orangeAccent),
              ),
            );
          }
          return auth.isAuthenticated 
              ? const DashboardScreen(key: ValueKey('Dashboard')) 
              : const WelcomeScreen(key: ValueKey('Welcome'));
        },
      ),
    );
  }
}
