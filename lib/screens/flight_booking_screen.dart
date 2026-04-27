import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlightBookingScreen extends StatelessWidget {
  const FlightBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Enter info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            _buildProgressIndicator(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInsuranceClaimBanner(),
            _buildPassengerSection(),
            _buildContactSection(),
            _buildInsuranceSection(),
            _buildBaggageSection(),
            _buildRewardsSection(),
            _buildTermsSection(),
            const SizedBox(height: 100), // Space for sticky footer
          ],
        ),
      ),
      bottomSheet: _buildStickyFooter(),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _circleStep('1', true),
        _lineStep(),
        _circleStep('2', true),
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
    return Container(width: 8, height: 1, color: Colors.grey.shade300);
  }

  Widget _buildInsuranceClaimBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A customer received AED 3,300 on Trip Curtailment Claim',
                  style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '"Deliveredpromises. Easy to claim. Good customer support. I\'m happy with the service. I will continue to use your service in the future."',
            style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('First & middle name(s) (e.g. John Peter)', 'Required, match ID'),
          _buildTextField('Last name (e.g. Smith)', 'Required, match ID'),
          _buildTextField('Date of birth', 'YYYY-MM-DD', icon: Icons.calendar_today),
          _buildTextField('ID type', 'Passport', icon: Icons.chevron_right),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.safarBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save & add passenger'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Done', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Contact name', 'Tamer'),
          Row(
            children: [
              Container(
                width: 70,
                child: _buildTextField('', '+971'),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField('Phone number', '50 123 4567')),
            ],
          ),
          _buildTextField('Email', 'tamerhael@gmail.com'),
        ],
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Insurance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text('I don\'t want to protect my trip', style: TextStyle(fontSize: 13, color: Colors.orange)),
                Spacer(),
                Icon(Icons.radio_button_off, size: 20, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, color: Colors.teal.shade300, size: 18),
                    const SizedBox(width: 8),
                    const Text('Protection Plans', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    const Spacer(),
                    const Icon(Icons.radio_button_off, size: 20, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Travel Insurance', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Worth AED 180,000 | Total 13 benefits >', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
                _buildInsuranceBenefit('Emergency Medical Costs Cover'),
                _buildInsuranceBenefit('Refund of flight costs if cancelled'),
                _buildInsuranceBenefit('Baggage loss and damage costs'),
                const SizedBox(height: 12),
                const Text('US\$48.12 /adult', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 12, color: Colors.teal),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.teal)),
        ],
      ),
    );
  }

  Widget _buildBaggageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Baggage allowance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Adding baggage now is cheaper than at the airport!', style: TextStyle(color: Colors.teal, fontSize: 12)),
          const SizedBox(height: 16),
          _buildBaggageRow(Icons.backpack, 'Personal item', 'Included in carry-on'),
          _buildBaggageRow(Icons.luggage, 'Carry-on baggage', '1 × 7 kg per person'),
          Row(
            children: [
              _buildBaggageRow(Icons.work, 'Checked baggage', '1 × 20 kg per person'),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safarBlue, foregroundColor: Colors.white),
                child: const Text('Add more'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.safarBlue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Trip Coins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              const Text('185 coins ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              Icon(Icons.monetization_on, color: Colors.orange.shade300, size: 20),
            ],
          ),
          const Divider(height: 32),
          const Row(
            children: [
              Text('Promo codes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Spacer(),
              Text('Please add passenger', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'By proceeding, I acknowledge that I have read and agree to safar.com\'s Terms of Use and Privacy Statement.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_box, color: AppTheme.safarBlue, size: 16),
              const SizedBox(width: 8),
              const Text('Send me special deals and updates', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Average price per person', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('US\$923.60', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.safarBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
