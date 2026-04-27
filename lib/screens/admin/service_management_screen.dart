import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ServiceManagementScreen extends StatelessWidget {
  final String title;
  const ServiceManagementScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة $title', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.safarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_suggest, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text('لوحة التحكم بـ $title قيد التطوير', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}
