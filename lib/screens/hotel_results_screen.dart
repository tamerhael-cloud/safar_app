import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'room_selection_screen.dart';

class HotelResultsScreen extends StatelessWidget {
  const HotelResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dubai', style: TextStyle(fontSize: 16)),
            Text('Apr 11 - Apr 13 • 2 Guests', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),
          // Hotel List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHotelItem(context, 'Atlantis The Palm', 'Palm Jumeirah', '\$450', '4.9', 5),
                _buildHotelItem(context, 'Burj Al Arab', 'Jumeirah', '\$1,200', '5.0', 5),
                _buildHotelItem(context, 'Address Downtown', 'Downtown Dubai', '\$380', '4.7', 5),
                _buildHotelItem(context, 'Hampton by Hilton', 'Dubai Airport', '\$32', '4.3', 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFilterChip('Price', Icons.keyboard_arrow_down),
          _buildFilterChip('Star Rating', Icons.keyboard_arrow_down),
          _buildFilterChip('Popularity', Icons.keyboard_arrow_down),
          _buildFilterChip('Location', Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Icon(icon, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildHotelItem(BuildContext context, String name, String location, String price, String rating, int stars) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoomSelectionScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 180,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/hotel_exterior.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.hotel, color: Colors.white, size: 50)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(stars, (index) => const Icon(Icons.star, size: 14, color: Colors.orange)),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total price for 2 nights', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        price,
                        style: const TextStyle(color: AppTheme.safarBlue, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
