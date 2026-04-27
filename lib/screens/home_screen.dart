import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'flight_search_screen.dart';
import 'hotel_search_screen.dart';
import 'generic_search_screen.dart';
import 'visa_application_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(height: 520, width: double.infinity), // Spacer to ensure hit testing
                _buildHeroHeader(),
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: _buildServiceGrid(context),
                ),
              ],
            ),
            const SizedBox(height: 20), // Reduced spacer
            _buildPromotionSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ).createShader(bounds),
          child: const Icon(Icons.auto_awesome, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.safarBlue, Color(0xFF0052D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'safar.com',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Row(
            children: [
              Icon(Icons.notifications_none, color: Colors.white),
              SizedBox(width: 16),
              Icon(Icons.headset_mic_outlined, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Services',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _buildServiceItem(context, 'Flights', Icons.flight, const FlightSearchScreen()),
              _buildServiceItem(context, 'Hotels', Icons.hotel, const HotelSearchScreen()),
              _buildServiceItem(context, 'Packages', Icons.card_travel, const GenericSearchScreen(title: 'Packages', icon: Icons.card_travel)),
              _buildServiceItem(context, 'Trains', Icons.train, const GenericSearchScreen(title: 'Trains', icon: Icons.train)),
              _buildServiceItem(context, 'Cars', Icons.directions_car, const GenericSearchScreen(title: 'Cars', icon: Icons.directions_car)),
              _buildServiceItem(context, 'Airport', Icons.local_taxi, const GenericSearchScreen(title: 'Airport Transfer', icon: Icons.local_taxi)),
              _buildServiceItem(context, 'Apartments', Icons.apartment, const GenericSearchScreen(title: 'Apartments', icon: Icons.apartment)),
              _buildServiceItem(context, 'Insurance', Icons.verified_user, const GenericSearchScreen(title: 'Insurance', icon: Icons.verified_user)),
              _buildServiceItem(context, 'Visa', Icons.assignment_ind, const VisaApplicationScreen()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String label, IconData icon, Widget target) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => target));
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.safarBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.safarBlue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top Summer Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromoCard('assets/images/hotel_exterior.png', 'Atlantis Dubai', 'From \$450'),
                _buildPromoCard('assets/images/infinity_pool.png', 'Bali Escape', 'From \$120'),
                _buildPromoCard('assets/images/luxury_suite.png', 'London Luxury', 'From \$320'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String img, String title, String price) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(img, height: 100, width: 160, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(color: AppTheme.safarBlue, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
