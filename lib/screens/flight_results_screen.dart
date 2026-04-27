import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'flight_fare_screen.dart';

class FlightResultsScreen extends StatelessWidget {
  const FlightResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Muscat ✈ Beijing', style: TextStyle(fontSize: 16)),
            Text('Sat, Apr 11 • 1 Passenger', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFlightCard(context, '08:45', '22:15', 'Oman Air', '\$906', '1 stop • 11h 30m'),
          _buildFlightCard(context, '02:30', '16:00', 'Qatar Airways', '\$1,120', '1 stop • 10h 30m'),
          _buildFlightCard(context, '10:00', '23:50', 'Emirates', '\$1,350', '1 stop • 9h 50m'),
        ],
      ),
    );
  }

  Widget _buildFlightCard(BuildContext context, String dep, String arr, String air, String price, String dur) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FlightFareScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dep, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('MCT', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.airplanemode_active, size: 16, color: Colors.grey),
                    Text(dur, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Container(height: 1, width: 60, color: Colors.grey.shade300),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(arr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('PEK', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 10, backgroundColor: AppTheme.safarBlue),
                    const SizedBox(width: 8),
                    Text(air, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
