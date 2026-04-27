import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService();
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(lang.translate('الإعدادات', 'Settings'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: AppTheme.safarBlue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(lang.translate('اللغة', 'Language')),
            ListTile(
              title: const Text('العربية'),
              trailing: lang.isArabic ? const Icon(Icons.check, color: AppTheme.safarBlue) : null,
              onTap: () => lang.setLocale(const Locale('ar')),
            ),
            ListTile(
              title: const Text('English'),
              trailing: !lang.isArabic ? const Icon(Icons.check, color: AppTheme.safarBlue) : null,
              onTap: () => lang.setLocale(const Locale('en')),
            ),
            const Divider(),
            _buildSectionHeader(lang.translate('التطبيق', 'App')),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(lang.translate('عن التطبيق', 'About App')),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(lang.translate('سياسة الخصوصية', 'Privacy Policy')),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.safarBlue),
      ),
    );
  }
}
