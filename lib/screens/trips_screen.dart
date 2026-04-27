import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import '../services/visa_service.dart';
import '../services/user_service.dart';
import '../services/external_api_service.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final _originController = TextEditingController(text: 'AMM');
  final _destController = TextEditingController(text: 'DXB');
  List<FlightSearchResult> _searchResults = [];
  bool _isLoading = false;

  void _searchFlights() async {
    setState(() => _isLoading = true);
    final results = await ExternalApiService().searchFlights(
      from: _originController.text,
      to: _destController.text,
      date: '2026-05-10', // Placeholder date
    );
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService();
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        appBar: AppBar(
          title: Text(lang.translate('البحث عن رحلات', 'Search Flights'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: AppTheme.safarBlue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchHeader(lang),
              if (_isLoading)
                const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
              else if (_searchResults.isNotEmpty)
                _buildResultsList(lang)
              else
                _buildVisaSection(context, lang),
              const SizedBox(height: 24),
              _buildRecommendedSection(lang),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(LanguageService lang) {
    return Container(
      color: AppTheme.safarBlue,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _originController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: lang.translate('من', 'From'),
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.flight_takeoff, color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _destController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: lang.translate('إلى', 'To'),
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.flight_land, color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _searchFlights,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.safarBlue),
              child: Text(lang.translate('بحث عن رحلات', 'Search Flights')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(LanguageService lang) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.translate('نتائج البحث', 'Search Results'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._searchResults.map((flight) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(flight.airline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('\$${flight.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.flight_takeoff, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(flight.departure, style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.flight_land, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(flight.arrival, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Text(lang.translate('رقم الرحلة: ', 'Flight: ') + flight.flightNumber, style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safarBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20)),
                        child: Text(lang.translate('حجز الآن', 'Book Now')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVisaSection(BuildContext context, LanguageService lang) {
    return ListenableBuilder(
      listenable: VisaService(),
      builder: (context, _) {
        final userService = UserService();
        final allApps = VisaService().applications;
        final apps = userService.role == UserRole.admin 
            ? allApps 
            : allApps.where((app) => app.submittedBy == userService.userName).toList();

        if (apps.isEmpty) return _buildTripHeader(lang);

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.translate('تأشيراتي', 'My Visas'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 12),
              ...apps.map((app) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: AppTheme.safarBlue),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${app.targetCountry} - ${app.visaType}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _getStatusColor(app.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text(app.status, style: TextStyle(color: _getStatusColor(app.status), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (app.status == 'مقبول' && app.approvedVisaFilePath != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (app.approvedVisaFilePath!.startsWith('http')) {
                              await launchUrl(Uri.parse(app.approvedVisaFilePath!));
                            } else {
                              await OpenFilex.open(app.approvedVisaFilePath!);
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: Text(lang.translate('عرض التأشيرة الصادرة', 'View Issued Visa')),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripHeader(LanguageService lang) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.luggage_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(lang.translate('لا توجد رحلات قادمة', 'No upcoming trips'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text(lang.translate('خطط لرحلتك القادمة الآن!', 'Keep planning and book your next adventure!'), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(LanguageService lang) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.translate('مقترح لك', 'Recommended for you'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          _buildRecommendedCard(lang, 'دبي، الإمارات', 'Luxury hotels and world-class shopping.', 'From \$180'),
          const SizedBox(height: 16),
          _buildRecommendedCard(lang, 'المالديف', 'Breathtaking overwater villas and clear waters.', 'From \$450'),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(LanguageService lang, String title, String desc, String price) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 140, width: double.infinity, decoration: BoxDecoration(color: AppTheme.safarBlue.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))), child: const Icon(Icons.image, color: Colors.white, size: 40)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.safarBlue))]),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'مقبول') return Colors.green;
    if (status == 'مرفوض' || status == 'تم رفض الدفع') return Colors.red;
    if (status == 'قيد المعاملة') return Colors.blue;
    if (status == 'بانتظار تأكيد الدفع') return Colors.orange;
    return Colors.orange;
  }
}
