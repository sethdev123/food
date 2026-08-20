import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email');
    if (email != null) {
      setState(() {
        _emailController.text = email;
      });
    }
  }

  void _showServerUrlDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Backend API URL',
            hintText: 'http://192.168.1.100:8000/api',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.setBaseUrl(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Server URL updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() => _isLoading = true);
    final success = await Provider.of<AuthProvider>(context, listen: false)
        .login(_emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('remembered_email', _emailController.text.trim());
      } else {
        await prefs.remove('remembered_email');
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final msg = auth.lastError ?? Provider.of<LocaleProvider>(context, listen: false).translate('invalid_credentials');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final size = MediaQuery.of(context).size;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: SafeArea(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: size.height * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D2D44) : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.orangeAccent, size: 18),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D2D44) : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                              ],
                            ),
                            child: const Icon(Icons.settings, color: Colors.orangeAccent, size: 18),
                          ),
                          onPressed: _showServerUrlDialog,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      localeProvider.translate('welcome_back'),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localeProvider.translate('sign_in_continue'),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D2D44) : Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.white.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            decoration: InputDecoration(
                              labelText: localeProvider.translate('email'),
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF3A3A52) : Colors.orange.withValues(alpha: 0.05),
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.orangeAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            decoration: InputDecoration(
                              labelText: localeProvider.translate('password'),
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF3A3A52) : Colors.orange.withValues(alpha: 0.05),
                              prefixIcon: const Icon(Icons.lock_outlined, color: Colors.orangeAccent),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.orangeAccent,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: Colors.orangeAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (value) => setState(() => _rememberMe = value!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localeProvider.translate('remember_email'),
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8A65), Color(0xFFFF6D00)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Text(
                                        localeProvider.translate('login'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localeProvider.translate('dont_have_account'),
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                    FadeTransition(opacity: animation, child: child),
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                          child: Text(
                            localeProvider.translate('register'),
                            style: GoogleFonts.poppins(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
