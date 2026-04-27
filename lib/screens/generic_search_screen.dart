import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GenericSearchScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const GenericSearchScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text('Search $title', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Icon(icon, size: 80, color: AppTheme.safarBlue.withOpacity(0.2)),
                  const SizedBox(height: 24),
                  _buildSearchField(Icons.search, 'Find $title', 'Enter search term...'),
                  const Divider(height: 32),
                  _buildSearchField(Icons.calendar_today, 'Date', 'Select preferred date'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Search Results for $title coming soon!')),
                      );
                    },
                    child: Text('Search $title'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.safarBlue, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          ],
        ),
      ],
    );
  }
}
