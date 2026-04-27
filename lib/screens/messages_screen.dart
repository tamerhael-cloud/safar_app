import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.headset_mic_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category Icons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                   _buildCategoryItem(Icons.chat_bubble_outline, 'Chats'),
                   _buildCategoryItem(Icons.event_available, 'Bookings'),
                   _buildCategoryItem(Icons.text_fields, 'Trip Rewards'),
                   _buildCategoryItem(Icons.card_giftcard, 'Promotions'),
                   _buildCategoryItem(Icons.assignment, 'Activities'),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1, height: 1),
          // Notifications List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Recent notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildNotificationCard(
                  'Grab a \$100 hotel coupon @ 11 PT 🎟️',
                  'Easter flash deals across Asia and America 🔔',
                  'Apr 1',
                ),
                _buildNotificationCard(
                  'Flash sale: flights up to \$200 off 🏷️',
                  'Easter flash drop at 11am—limited quantities on popular routes 🍜',
                  'Mar 31',
                ),
                _buildNotificationCard(
                  'Your promo code will expire soon - don\'t miss this chance!',
                  'Don\'t let these deals slip through your fingers. Use a promo code now!',
                  'Mar 30',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.safarBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.safarBlue, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String title, String subtitle, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.card_giftcard, color: Colors.pink.shade300, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              TextButton(
                onPressed: () {},
                child: const Text('View details', style: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
