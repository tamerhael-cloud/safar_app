import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'hotel_booking_screen.dart';

class RoomSelectionScreen extends StatelessWidget {
  const RoomSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Atlantis The Palm', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Palm Jumeirah, Dubai, United Arab Emirates', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  _buildAmenitiesSection(),
                  const SizedBox(height: 24),
                  const Text('Select Room', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildRoomCard(context, 'Deluxe Ocean Room', 'King/Twin Bed • 45m²', '\$450', 'assets/images/deluxe_room.png'),
                  _buildRoomCard(context, 'Palm Beach Suite', 'King Bed • 47m² • Ocean View', '\$580', 'assets/images/luxury_suite.png'),
                  _buildRoomCard(context, 'Infinity Pool Villa', 'Private Pool Included • 52m²', '\$750', 'assets/images/infinity_pool.png'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppTheme.safarBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(
          'assets/images/hotel_exterior.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.hotel, size: 80, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAmenityIcon(Icons.wifi, 'Free WiFi'),
          _buildAmenityIcon(Icons.pool, 'Pool'),
          _buildAmenityIcon(Icons.fitness_center, 'Gym'),
          _buildAmenityIcon(Icons.restaurant, 'Breakfast'),
          _buildAmenityIcon(Icons.spa, 'Spa'),
        ],
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, String title, String subtitle, String price, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.bed, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                  const Text('per night', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HotelBookingScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.safarBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Book Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
