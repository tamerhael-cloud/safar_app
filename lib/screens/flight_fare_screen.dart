import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'flight_booking_screen.dart';

class FlightFareScreen extends StatelessWidget {
  const FlightFareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Select fare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            _buildProgressIndicator(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'The prices below do not include Trip.com booking fee which will be displayed after you select a fare ⓘ',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            // Fare Price Card
            _buildFarePriceCard(context),
            const SizedBox(height: 16),
            // Baggage FAQ Section
            _buildBaggageFAQSection(),
            const SizedBox(height: 24),
            // Footer Info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text('Book with confidence on safar.com', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.blue),
                      Text(' Award-winning • Support in approx. 30s', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _circleStep('1', true),
        _lineStep(),
        _circleStep('2', false),
        _lineStep(),
        _circleStep('3', false),
        _lineStep(),
        _circleStep('4', false),
      ],
    );
  }

  Widget _circleStep(String num, bool isActive) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }

  Widget _lineStep() {
    return Container(width: 10, height: 1, color: Colors.grey.shade300);
  }

  Widget _buildFarePriceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('US\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                  Text('906', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                  Text(' /person', style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FlightBookingScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.safarBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.luggage, 'Carry-on baggage: 1 × 7 kg'),
          _buildInfoRow(Icons.work, 'Checked baggage: 1 × 20 kg'),
          _buildInfoRow(Icons.close, 'Non-refundable', iconColor: Colors.red),
          _buildInfoRow(Icons.change_circle_outlined, 'Change fee: from US\$187'),
          _buildInfoRow(Icons.access_time, 'Ticketing: Within 12 hours after payment'),
          const Divider(height: 32),
          const Center(
            child: Text('Economy class • View details >', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color iconColor = Colors.teal}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBaggageFAQSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue.shade300, size: 20),
              const SizedBox(width: 8),
              const Text('Got any questions about baggage? Ask me!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildFAQItem('Do my handbag and laptop bag count as two carry-on items?'),
          _buildFAQItem('How much baggage can I check in?'),
          _buildFAQItem('Will I need to re-check my baggage during the transfer?'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Ask our AI assistant'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
