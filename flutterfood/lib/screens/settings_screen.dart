import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localeProvider.translate('settings'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: ListView(
        children: [
          SwitchListTile(
            title: Text(
              localeProvider.translate('dark_mode'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Enable dark theme for the app'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.orangeAccent,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.orangeAccent),
            title: Text(
              localeProvider.translate('language'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(localeProvider.locale.languageCode == 'en' ? 'English' : 'ភាសាខ្មែរ (Khmer)'),
            trailing: DropdownButton<String>(
              value: localeProvider.locale.languageCode,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  localeProvider.setLocale(Locale(newValue));
                }
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'km', child: Text('ខ្មែរ')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              localeProvider.translate('version'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            leading: const Icon(Icons.info_outline, color: Colors.orangeAccent),
          ),
        ],
      ),
      ),
    );
  }
}
